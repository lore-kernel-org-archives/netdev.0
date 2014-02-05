From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 70071] New: Sending netconsole messages over a bridged
 network interface doesn't work anymore
Date: Wed, 5 Feb 2014 14:15:39 -0700
Message-ID: <20140205141539.450095fa@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:51521 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932414AbaBEVPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 16:15:55 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so840418pde.21
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 13:15:55 -0800 (PST)
Received: from samsung-9 (ip01.wsr-guests.simplybits.net. [64.119.35.90])
        by mx.google.com with ESMTPSA id sx8sm204207836pab.5.2014.02.05.13.15.50
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Feb 2014 13:15:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 5 Feb 2014 04:36:03 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 70071] New: Sending netconsole messages over a bridged network interface doesn't work anymore


https://bugzilla.kernel.org/show_bug.cgi?id=70071

            Bug ID: 70071
           Summary: Sending netconsole messages over a bridged network
                    interface doesn't work anymore
           Product: Networking
           Version: 2.5
    Kernel Version: 3.12
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: bvanassche@acm.org
        Regression: Yes

Apparently several users already ran into this issue. See e.g.:
http://thread.gmane.org/gmane.linux.network/288373
http://lists.suse.de/archive/opensuse-kernel/2014-01/msg00061.html

-- 
You are receiving this mail because:
You are the assignee for the bug.
