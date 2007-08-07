From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 8845] New: Kernel 2.6.23-RC2: TCP + ICH9 + Amule + Hours =
 Freeze of my Debian => Reboot
Date: Tue, 7 Aug 2007 09:37:31 -0400
Message-ID: <20070807093731.11a6e87a@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39979 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761321AbXHGNhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 09:37:01 -0400
Received: from oldman (pool-141-154-144-75.wma.east.verizon.net [141.154.144.75])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l77DavX1032332
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 7 Aug 2007 06:37:00 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Any takers?

Subject: [Bug 8845] New: Kernel 2.6.23-RC2: TCP + ICH9 + Amule + Hours = Freeze of my Debian => Reboot


http://bugzilla.kernel.org/show_bug.cgi?id=8845

           Summary: Kernel 2.6.23-RC2: TCP + ICH9 + Amule + Hours = Freeze
                    of my Debian => Reboot
           Product: Networking
           Version: 2.5
     KernelVersion: Kernel 2.6.23-RC2
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@osdl.org
        ReportedBy: v4ahixbmb4@forgetably.com


Hello!

I had the same problem with kernel 2.6.22.
I have a very recent Asus P5K-VM motherboard, and with the same harddrive and
software on an Asus P5B-VM I had no problem. I have no problem with Ktorrent.

When I use amule with only the udp mode (Kademlia), my Debian Etch/Lenny works
alright for 24 hours straight, with dozens of active downloads.
When I use the regular tcp mode (edonkey protocol), after 3 hours my Debian
completely freezes (no hardrive activity, no console accessible, impossible to
trigger a reboot from the keyboard with the right sequence of keys), and I have
to reboot.
I reproduced this more than ten times.
I use an old D-Link DFE-530TX ethernet card with which I never had any problem
over the years. I have a cable internet connection (1 MB/s up/ 30MB/s down)
There is nothing in the logs before the freeze.


-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
