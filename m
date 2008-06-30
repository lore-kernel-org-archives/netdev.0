From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: (usagi-users 04056) Re: ping6 is sent out from wrong interface
Date: Mon, 30 Jun 2008 21:57:23 +0900
Message-ID: <4868D833.4000900@miraclelinux.com>
References: <4861ED72.6080100@miraclelinux.com> <20080628.041404.82719082.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: usagi-users@ml.linux-ipv6.org, netdev@vger.kernel.org,
	usagi-users@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:22773 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbYF3M5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 08:57:25 -0400
In-Reply-To: <20080628.041404.82719082.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi YOSHIFUJI-san

Thanks for your proposal.

> > In theory, outgoing interface must be selected by routing, if unspecified.
> > So, I'd propose something like this (not tested, not for real patch).

This patch looks good enough to me.
I tested your patch and it works as I expected.
I'm looking forward to seeing your final fix as well.

Thank you so much.
Naohiro Ooiwa
