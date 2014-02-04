function bytesToString(bytes)
{
        var sign = (bytes < 0 ? "-" : "");
        var readable = (bytes < 0 ? -bytes : bytes);
        var suffix;
        if (bytes >= 0x1000000000000000) // Exabyte
        {
            suffix = "EB";
            readable = (bytes >> 50);
        }
        else if (bytes >= 0x4000000000000) // Petabyte
        {
            suffix = "PB";
            readable = (bytes >> 40);
        }
        else if (bytes >= 0x10000000000) // Terabyte
        {
            suffix = "TB";
            readable = (bytes >> 30);
        }
        else if (bytes >= 0x40000000) // Gigabyte
        {
            suffix = "GB";
            readable = (bytes >> 20);
        }
        else if (bytes >= 0x100000) // Megabyte
        {
            suffix = "MB";
            readable = (bytes >> 10);
        }
        else if (bytes >= 0x400) // Kilobyte
        {
            suffix = "KB";
            readable = bytes;
        }
        else
        {
            return sign + "0 B" // Byte
        }
        readable = readable / 1024;

        return sign + (Math.round(readable * 100) / 100) + " " + suffix;
}
