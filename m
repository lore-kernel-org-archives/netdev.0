From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4434] New: Tulip based NIC card causes hard
 lock up of PC
Date: Sat, 2 Apr 2005 01:56:22 -0800
Message-ID: <20050402015622.41dff439.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel@wpascanner.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sat, 2 Apr 2005 01:49:50 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4434] New: Tulip based NIC card causes hard lock up of PC


http://bugme.osdl.org/show_bug.cgi?id=4434

           Summary: Tulip based NIC card causes hard lock up of PC
    Kernel Version: 2.6.11
            Status: NEW
          Severity: high
             Owner: acme@conectiva.com.br
         Submitter: kernel@wpascanner.com


Distribution: Knoppix V3.8 CeBIT, V3.7 PC-Welt, ANY Knoppix under kernel 2.6.x
Hardware Environment: #1 FIC PA-2007 MB 160MB RAM BIOS V1.09CD12
                      #2 ABIT K7R MB 384MB RAM
                      LAN Cards OEM DEC Tulip 21041 DLink DE-530+
                      LAN Cards Intel 21143 Tulip based

Software Environment: de4x5

Problem Description: Hard lock up on setting up LAN/NIC card

Steps to reproduce: Can not boot to working enviroment with DHCP enabled 
(default for Knoppix) or after booting via NODHCP cheat code on command line 
and using netcardconfig results in the hard lock up.

See:
http://www.knoppix.net/forum/viewtopic.php?t=17985&highlight=
http://www.knoppix.net/forum/viewtopic.php?t=17986&highlight=

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
