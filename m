From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Fw: [Bug 57251] New: HUAWEI 3G USB modem and abnormal stops
Date: Mon, 29 Apr 2013 15:48:44 -0700
Message-ID: <20130429154844.61abe852@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?B?Qmr4cm4=?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sun, 28 Apr 2013 18:52:29 -0700
From: "bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org" <bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org>
To: "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: [Bug 57251] New: HUAWEI 3G USB modem and abnormal stops


https://bugzilla.kernel.org/show_bug.cgi?id=57251

           Summary: HUAWEI 3G USB modem and abnormal stops
           Product: Networking
           Version: 2.5
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
        ReportedBy: zonadomarquinhos-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
        Regression: No


first, excuse me for not here for details about the types of information, logs
and debugs I could leave here because I do not know the kind of information I
could put here. 

if they need more information and details, tell me! 

independent of the kernel version used the problem is this: 
when I'm surfing the internet network flow (upload and download) can not stop
and browse pages, this problem does not have a right time to happen. 

when I disconnect, I can, but when trying to connect to the internet again and
I can not only get when I take the usb modem and put again, retracing the
process of connecting to the internet I can with success. this happens many
times a day! 

My modem is: 
HUAWEI 3G USB Modem Model: E1553, Operator (Brazil) Oi 2G 

My system is: Arch Linux i686 

information by lsusb is:
% lsusb
Bus 003 Device 002: ID 12d1:1001 Huawei Technologies Co., Ltd. E169/E620/E800
HSDPA Modem
Bus 004 Device 002: ID 15d9:0a4c Trust International B.V. USB+PS/2 Optical
Mouse
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub

sorry by my english, i are using Google Translate for this.
and remeber! if need more informations, tell me!

tnx by all!

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
