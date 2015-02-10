From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 93011] New: boilerplate IPVLAN Kconfig
Date: Mon, 9 Feb 2015 22:49:13 -0800
Message-ID: <20150209224913.24e48ffa@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:60759 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbbBJGtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 01:49:16 -0500
Received: by mail-pa0-f51.google.com with SMTP id eu11so17440574pac.10
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 22:49:16 -0800 (PST)
Received: from uryu.home.lan ([209.37.255.2])
        by mx.google.com with ESMTPSA id o3sm18292967pde.7.2015.02.09.22.49.15
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Feb 2015 22:49:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 9 Feb 2015 22:06:03 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 93011] New: boilerplate IPVLAN Kconfig


https://bugzilla.kernel.org/show_bug.cgi?id=93011

            Bug ID: 93011
           Summary: boilerplate IPVLAN Kconfig
           Product: Networking
           Version: 2.5
    Kernel Version: 3.19
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: low
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: bugzilla.kernel.bpeb@manchmal.in-ulm.de
        Regression: No

Hi there,

3.19 introduced a new option IPVLAN, however the text in
drivers/net/Kconfig still contains a template:

|      Ipvlan devices can be added using the "ip" command from the
|      iproute2 package starting with the iproute2-X.Y.ZZ release:

Please update to the appropriate version number.

-- 
You are receiving this mail because:
You are the assignee for the bug.
