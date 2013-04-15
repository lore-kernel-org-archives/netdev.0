From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 56641] New: Kernel looses networking connectivity
Date: Mon, 15 Apr 2013 10:22:19 -0700
Message-ID: <20130415102219.2e5542f7@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:54226 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068Ab3DORWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:22:30 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so2594636pdi.7
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 10:22:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 15 Apr 2013 10:17:27 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 56641] New: Kernel looses networking connectivity


https://bugzilla.kernel.org/show_bug.cgi?id=56641

           Summary: Kernel looses networking connectivity
           Product: Networking
           Version: 2.5
    Kernel Version: 3.7 to 3.8
          Platform: All
        OS/Version: Linux
              Tree: Fedora
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: g0tt@rocketmail.com
        Regression: Yes


In my home network I have a Belkin router with an older DD-WRT firmware.
Everything was running fine with Windows 7 and Ubuntu 12.04.
Trouble startet with the new OpenSuse (12.3?) with kernel 3.7 on my desktop
machine. Wired networking would just stop working.
Same problem on my netbook with Ubuntu 13.04 and wireless networking, with
12.04 and kernel 3.5 things are much better, with 3.2 it was perfect.
I tried installing Fedora and Arch on my desktop, but the problem persists with
kernel 3.8. My wild guess is that newer kernels networking code rubs my Belkin
router the wrong way, but I don't know what kernel settings I need to change.
Thanks in advance.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
