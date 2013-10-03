From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 62491] New: alx 0000:02:00.0: invalid PHY speed/duplex:
 0xffff
Date: Thu, 3 Oct 2013 10:40:41 -0700
Message-ID: <20131003104041.324badf5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:39700 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351Ab3JCRkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 13:40:47 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so2778740pbc.2
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 10:40:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 3 Oct 2013 10:21:34 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 62491] New: alx 0000:02:00.0: invalid PHY speed/duplex: 0xffff


https://bugzilla.kernel.org/show_bug.cgi?id=62491

            Bug ID: 62491
           Summary: alx 0000:02:00.0: invalid PHY speed/duplex: 0xffff
           Product: Networking
           Version: 2.5
    Kernel Version: 3.12-rc3
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: vaniaz@msn.com
        Regression: No

Hardware: lenovo g780 using alx network driver; software - opensuse tambleweed
with kernel 3.12-rc3.
After entering sleep mode and waking up console at alt + f is flooding with
messages like:
[672.000000] alx 0000:02:00.0: invalid PHY speed/duplex: 0xffff

-- 
You are receiving this mail because:
You are the assignee for the bug.
