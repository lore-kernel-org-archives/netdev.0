From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 80201] general protection fault: 0000 [#1] SMP (while
 using HTB)
Date: Wed, 23 Jul 2014 11:01:14 -0700
Message-ID: <20140723110114.2b142ab1@haswell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:40776 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932462AbaGWSBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 14:01:14 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so2202837pab.2
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 11:01:14 -0700 (PDT)
Received: from haswell (static-50-53-72-226.bvtn.or.frontiernet.net. [50.53.72.226])
        by mx.google.com with ESMTPSA id j6sm4022098pdn.23.2014.07.23.11.01.11
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jul 2014 11:01:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 23 Jul 2014 04:35:01 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 80201] general protection fault: 0000 [#1] SMP (while using HTB)


https://bugzilla.kernel.org/show_bug.cgi?id=80201

--- Comment #1 from Cenek Zach <cenek.zach@gmail.com> ---
Created attachment 144021
  --> https://bugzilla.kernel.org/attachment.cgi?id=144021&action=edit
Kernel GPF stack trace 2

-- 
You are receiving this mail because:
You are the assignee for the bug.
