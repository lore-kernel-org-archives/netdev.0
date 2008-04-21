From: David Miller <davem@davemloft.net>
Subject: Re: New GIT net tree naming...
Date: Mon, 21 Apr 2008 00:56:32 -0700 (PDT)
Message-ID: <20080421.005632.222665335.davem@davemloft.net>
References: <20080419.173510.257216556.davem@davemloft.net>
	<d0383f90804210053w538c20dfp6495072632320abe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ianbrn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60596
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752831AbYDUH4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 03:56:30 -0400
In-Reply-To: <d0383f90804210053w538c20dfp6495072632320abe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ian Brown" <ianbrn@gmail.com>
Date: Mon, 21 Apr 2008 10:53:16 +0300

> Sorry for my ignorance, but what is the password that I need to enter
> when prompted to ?
> 
> when running:
> git-clone master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master
> Initialized empty Git repository in /work/src/master/.git/
> I get:
> root@master.kernel.org's password:
> 
> The same is for the
> master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git
> tree.

The URL I posted works for people who have kernel.org accounts.

Others, such as yourself, need to transform that URL into the
public form, for example:

	git://.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git

and:

	git://.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
