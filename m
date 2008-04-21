From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: New GIT net tree naming...
Date: Mon, 21 Apr 2008 17:00:26 +0900 (JST)
Message-ID: <20080421.170026.131839483.yoshfuji@linux-ipv6.org>
References: <20080419.173510.257216556.davem@davemloft.net>
	<d0383f90804210053w538c20dfp6495072632320abe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: ianbrn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34260 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbYDUH6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 03:58:31 -0400
In-Reply-To: <d0383f90804210053w538c20dfp6495072632320abe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <d0383f90804210053w538c20dfp6495072632320abe@mail.gmail.com> (at Mon, 21 Apr 2008 10:53:16 +0300), "Ian Brown" <ianbrn@gmail.com> says:

> when running:
> git-clone master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master
> Initialized empty Git repository in /work/src/master/.git/
> I get:
> root@master.kernel.org's password:
> 
> The same is for the
> master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git
> tree.

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

I'd not recommend to run git as root, BTW.

--yoshfuji
