From: linux fan <linuxscratch@gmail.com>
Subject: Re: [PATCH] net: Support inclusion of <linux/socket.h> before
Date: Tue, 29 Dec 2009 15:52:13 -0500
Message-ID: <e999a5f70912291252p213ad286h96237ef10eab409e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, ben@decadent.org.uk, waldi@debian.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:33554 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbZL2UwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 15:52:15 -0500
Received: by bwz27 with SMTP id 27so7180608bwz.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 12:52:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 [PATCH] net: Support inclusion of <linux/socket.h> before
causes strace to fail to compile

http://marc.info/?l=linux-netdev&m=126196079915202&w=2
http://linuxfromscratch.org/pipermail/blfs-support/2009-December/066157.html
http://marc.info/?l=linux-netdev&m=126196079915202&w=2
