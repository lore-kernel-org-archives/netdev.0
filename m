From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: [PATCH] correct typo in __xfrm4_bundle_create()
Date: Wed, 5 Dec 2007 15:59:52 +0200
Message-ID: <d0383f90712050559o7ad78dbbm51f74984b591e66d@mail.gmail.com>
References: <d0383f90712050249q3bc0e249h4cb66dc0ea97f172@mail.gmail.com>
	 <20071205.052034.251196808.davem@davemloft.net>
	 <d0383f90712050541p5d8ffce6q8748d7c6b66ea9c6@mail.gmail.com>
	 <20071205.054711.186439758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:14897 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbXLEOAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 09:00:00 -0500
Received: by py-out-1112.google.com with SMTP id u77so76929pyb
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2007 05:59:58 -0800 (PST)
In-Reply-To: <20071205.054711.186439758.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Sorry ; but is this tree can be fetched ? it requires a password.

I try:
git-clone kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.25.git net-2.6.25
and get:
root@kernel.org's password:

Ian

On Dec 5, 2007 3:47 PM, David Miller <davem@davemloft.net> wrote:
> From: "Ian Brown" <ianbrn@gmail.com>
> Date: Wed, 5 Dec 2007 15:41:37 +0200
>
> > Hello,
> > Sorry; I was not aware of it; I am sending here  the patch as an attachment.
> > It is a typo correction in __xfrm4_bundle_create() in net/ipv4/xfrm4_policy.c;
> >  it should be "Copy neighbour" instead "Copy neighbout"
>
> __xfrm4_bundle_create() no longer exists in the networking
> development tree:
>
>         kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.25.git
>
> Because Herbert Xu unified much of the IPSEC handling
> paths over the past few weeks.
>
