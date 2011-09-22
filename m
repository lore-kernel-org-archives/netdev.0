From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: routing table error in 2.6.39 ..
Date: Thu, 22 Sep 2011 21:25:47 +0530
Message-ID: <CAGZFCEHtyE1MutMmhKefFm9Xx5rri1j7DR7L=cFU3KUg7ejs4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: user-mode-linux-user@lists.sourceforge.net,
	user-mode-linux-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:48209 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154Ab1IVPzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 11:55:48 -0400
Received: by gyg10 with SMTP id 10so1924697gyg.19
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2011 08:55:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I built UML  (user mode linux ) for 2.6.38 and 2.6.39 kernels.

in 2.6.38 routing  table is  correct. But in 2.6.39 default gw appears
on top of the routing table. same problem persist in 3.0.0 also.

is it a known problem or fixed in higher versions ?

-Ratheesh
