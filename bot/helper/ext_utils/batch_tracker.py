from time import time
from bot.helper.telegram_helper.message_utils import sendMessage
from bot.helper.ext_utils.human_format import get_readable_file_size


class FileUploadInfo:
    """Stores metadata for a single uploaded file"""

    def __init__(self, name, size, extension, upload_duration, status, link=None):
        self.name = name
        self.size = size  # Already formatted as string (e.g., "1.5 GB")
        self.extension = extension
        self.upload_duration = upload_duration  # In seconds
        self.status = status  # "success" or "failed"
        self.link = link  # Upload link (for mirror mode)
        self.upload_time = time()


class BatchUploadTracker:
    """Tracks and summarizes batch upload operations"""

    BATCH_TIMEOUT = 3600  # 1 hour timeout for abandoned batches

    def __init__(self, batch_id, total_files, batch_owner_message, is_leech):
        self.batch_id = batch_id
        self.total_files = total_files
        self.completed_files = []  # List of FileUploadInfo objects
        self.failed_files = []  # List of FileUploadInfo objects
        self.batch_message = batch_owner_message  # Original /mb command message
        self.is_leech = is_leech  # True for leech, False for mirror
        self.start_time = time()
        self.cancelled = False

    def add_completed_upload(self, file_info):
        """Record a successful upload"""
        self.completed_files.append(file_info)

    def add_failed_upload(self, file_info):
        """Record a failed upload"""
        self.failed_files.append(file_info)

    def is_complete(self):
        """Check if all uploads are done (completed + failed == total)"""
        if self.cancelled:
            return False  # Don't send summary if cancelled
        return len(self.completed_files) + len(self.failed_files) >= self.total_files

    def is_timed_out(self):
        """Check if batch has exceeded timeout"""
        return time() - self.start_time > self.BATCH_TIMEOUT

    def cancel_batch(self):
        """Mark batch as cancelled - won't send summary"""
        self.cancelled = True

    async def send_summary(self):
        """Generate and send the batch upload summary message"""
        from html import escape

        # Calculate total batch time
        total_time = int(time() - self.start_time)

        # Build summary message
        msg = "═══════════════════════\n"
        msg += "📊 <b>BATCH UPLOAD SUMMARY</b>\n"
        msg += "═══════════════════════\n\n"

        msg += f"✅ <b>Completed:</b> {len(self.completed_files)}/{self.total_files}\n"
        if self.failed_files:
            msg += f"❌ <b>Failed:</b> {len(self.failed_files)}\n"

        msg += f"⏱ <b>Total Time:</b> {self._format_duration(total_time)}\n"
        msg += f"📁 <b>Mode:</b> {'Leech' if self.is_leech else 'Mirror'}\n\n"

        # List successful uploads
        if self.completed_files:
            msg += "━━━━━━━━━━━━━━━━━━━━━\n"
            msg += "<b>📤 Uploaded Files:</b>\n\n"

            for idx, file in enumerate(self.completed_files, 1):
                duration_str = self._format_duration(int(file.upload_duration))

                msg += f"{idx}. <code>{escape(file.name)}</code>\n"
                msg += f"   📦 Size: {file.size} | 🏷 Ext: {file.extension or 'N/A'} | ⏱ Time: {duration_str}\n"

                # Limit message size - Telegram has 4096 char limit
                if len(msg) > 3500:
                    remaining = len(self.completed_files) - idx
                    msg += f"\n<i>... and {remaining} more file{'s' if remaining > 1 else ''}</i>\n"
                    break

        # List failed uploads
        if self.failed_files:
            msg += "\n━━━━━━━━━━━━━━━━━━━━━\n"
            msg += "<b>❌ Failed Uploads:</b>\n\n"
            for idx, file in enumerate(self.failed_files, 1):
                msg += f"{idx}. <code>{escape(file.name or 'Unknown file')}</code>\n"

                # Also check size limit for failed files
                if len(msg) > 3800:
                    remaining = len(self.failed_files) - idx
                    if remaining > 0:
                        msg += f"\n<i>... and {remaining} more</i>\n"
                    break

        msg += "\n═══════════════════════\n"
        msg += "🤖 <i>Batch upload complete!</i>"

        # Send summary to the user
        await sendMessage(msg, self.batch_message)

    @staticmethod
    def _format_duration(seconds):
        """Format duration in seconds to human-readable format"""
        if seconds < 60:
            return f"{seconds}s"
        elif seconds < 3600:
            minutes = seconds // 60
            secs = seconds % 60
            return f"{minutes}m {secs}s"
        else:
            hours = seconds // 3600
            minutes = (seconds % 3600) // 60
            return f"{hours}h {minutes}m"
