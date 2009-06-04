From: nishit.shah@elitecore.com
Subject: Re: [PATCH] r8168: r8168 fixes
Date: Thu, 4 Jun 2009 12:13:25 +0530 (IST)
Message-ID: <43555.203.88.140.119.1244097805.squirrel@203.88.135.194>
References: <b2d58cb80906030144m6cb7c848se1fe5f471b4688ed@mail.gmail.com>
    <20090603.214751.98512113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhost.elitecore.com ([203.88.135.194]:52254 "EHLO
	elitecore.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752081AbZFDGnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 02:43:25 -0400
In-Reply-To: <20090603.214751.98512113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

>
> There is no file named r8168*, or anything like it, in the upstream
> kernel tree.
>
> You should not be submitting patches for out-of-tree drivers
> to this mailing list, thank you.
>

I am aware that r8168 is not a part of upstream kernel but I have
submitted the patch due to modinfo output of the driver,

[root@kernel-dev r8168]# modinfo r8168.ko
filename:       r8168.ko
version:        8.011.00-NAPI
license:        GPL
description:    RealTek RTL-8168 Gigabit Ethernet driver
author:         Realtek and the Linux r8168 crew <netdev@vger.kernel.org>
srcversion:     053AD75C2DC4A728C4477D9
alias:          pci:v000010ECd00008168sv*sd*bc*sc*i*

In author field, mail address in netdev@vger.kernel.org.

Rgds,
Nishit Shah.
