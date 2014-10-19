From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 86531] New: Kernel panic when using nmap
Date: Sun, 19 Oct 2014 22:11:49 +0530
Message-ID: <20141019221149.2b590638@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40694 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbaJSQnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 12:43:08 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so3666258pac.14
        for <netdev@vger.kernel.org>; Sun, 19 Oct 2014 09:43:08 -0700 (PDT)
Received: from uryu.home.lan ([14.141.84.68])
        by mx.google.com with ESMTPSA id sa6sm6932884pbb.29.2014.10.19.09.43.06
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 19 Oct 2014 09:43:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 19 Oct 2014 08:02:37 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 86531] New: Kernel panic when using nmap


https://bugzilla.kernel.org/show_bug.cgi?id=86531

            Bug ID: 86531
           Summary: Kernel panic when using nmap
           Product: Networking
           Version: 2.5
    Kernel Version: 3.17.1
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: alxchk@gmail.com
        Regression: No

Created attachment 154181
  --> https://bugzilla.kernel.org/attachment.cgi?id=154181&action=edit
Crash log #1

Strange crash appears the second time this day for me, when I starting nmap for
scanning. Couldn't find any dependency. Anyway, dumps attached.

-- 
You are receiving this mail because:
You are the assignee for the bug.
