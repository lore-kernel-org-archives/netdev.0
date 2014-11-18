From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Query about Dynamic Right Sizing implementation in linux-kernel
Date: Tue, 18 Nov 2014 06:07:01 -0800
Message-ID: <1416319621.14060.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <400045440.131017.1416304451861.JavaMail.root@mail.cse.iitm.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cprasad@cse.iitm.ac.in
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:57910 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414AbaKROHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 09:07:03 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so1088671iga.9
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 06:07:03 -0800 (PST)
In-Reply-To: <400045440.131017.1416304451861.JavaMail.root@mail.cse.iitm.ac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-18 at 15:24 +0530, cprasad@cse.iitm.ac.in wrote:
> Hi,
> 	 I found a DRS patch for verison 2.4.8 in lanl.gov page and I have no
> idea if it is incorporated into the kernel. So I would like to know if
> Dynamic Right Sizing(DRS) is implemented in kernel.If so from which
> version of kernel was it implemented?

It is implemented yes.

Last patch we did about that was for linux-3.13

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=b0983d3c9b132c33b6fb2e28d157a1edc18a173c
