# 🚀 Mounting NTFS USB with Maximum Performance on Linux

To mount an NTFS-formatted USB drive with optimized performance, use:

```bash
sudo mount -t ntfs-3g -o big_writes,noatime,windows_names /dev/sdX1 /mnt/usb
```

## 🔍 Explanation of Options
- `-t ntfs-3g`: Use the NTFS driver for Linux.
- `big_writes`: Batches write operations to improve speed.
- `noatime`: Prevents frequent disk writes by skipping last-access time updates.
- `windows_names`: Prevents creation of filenames that are invalid in Windows.

## 📌 Before Using
- Replace `/dev/sdX1` with your USB’s actual device (check with `lsblk`).
- Make sure `/mnt/usb` exists:

```bash
sudo mkdir -p /mnt/usb
```

## ✅ Benefits
- Faster file transfers compared to default mounting.
- Compatible with Windows.
- Reduces unnecessary disk I/O.

## ⚠️ Important
- Always run `sudo umount /mnt/usb` before unplugging to avoid corruption.
