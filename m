From: Frederic LAMBERT <frdrc66@gmail.com>
Subject: Driver for embedded switch Micrel KS8995MA
Date: Tue, 13 Dec 2011 19:33:25 +0100
Message-ID: <CAMVnO+nbtJjyjKXVnQz__A+91cUb6P7VSpkd=f67L1G=rP-dag@mail.gmail.com>
References: <CAMVnO+n1g1rV_xLhqHONFcSBxJJ6wU3a8vzQ623jZKv0wYnh+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:40375 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330Ab1LMSd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 13:33:26 -0500
Received: by yenm11 with SMTP id m11so5015278yen.19
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 10:33:25 -0800 (PST)
In-Reply-To: <CAMVnO+n1g1rV_xLhqHONFcSBxJJ6wU3a8vzQ623jZKv0wYnh+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found an quite old driver on the net for the 5-ports 10/100 embedded
switch Micrel KS8995MA.
It had to be updated a little bit because a parameter was missing to
the ks8995_registers_read() & write() functions.

I haven't been able to contact its original author, Gabor Juhos, who
wrote it in 2008 under GPL v2.

Is it possible to submit this driver as a patch to be included in the
distribution?
If yes, what would be the best place? driver/net/phy? driver/net/ethernet?

Thanks for advices,
--
Frederic
