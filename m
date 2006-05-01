From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6471] New: sky2 problem with Marvell 88E8055
Date: Mon, 1 May 2006 09:35:08 -0700
Message-ID: <20060501093508.78e6f4c8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, prb@du.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56209 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932146AbWEAQhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 12:37:16 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 1 May 2006 05:20:30 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6471] New: sky2 problem with Marvell 88E8055


http://bugzilla.kernel.org/show_bug.cgi?id=6471

           Summary: sky2 problem with Marvell 88E8055
    Kernel Version: 2.6.17-rc3
            Status: NEW
          Severity: high
             Owner: jgarzik@pobox.com
         Submitter: prb@du.se


Most recent kernel where this bug did not occur: 2.6.17-rc3
Distribution: Gentoo
Hardware Environment: Fujitsu-Siemens E8110, ethernet Card Marvell 88E8055
Software Environment:
Problem Description:
Unable to connect, sometimes kernel hangs

Steps to reproduce:
boot, modprobe sky2, dhclient -d eth1

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
