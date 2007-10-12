From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPUtils and uClibc
Date: Sat, 13 Oct 2007 05:26:43 +0900 (JST)
Message-ID: <20071013.052643.09349509.yoshfuji@linux-ipv6.org>
References: <46AD19BF.7090706@interia.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: rafalbilski@interia.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53645 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756370AbXJLUYu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 16:24:50 -0400
In-Reply-To: <46AD19BF.7090706@interia.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <46AD19BF.7090706@interia.pl> (at Mon, 30 Jul 2007 00:50:39 =
+0200), Rafa=B3 Bilski <rafalbilski@interia.pl> says:

> Today I was trying to update my router based on Gentoo and uClibc.=20
> Unfortunatly build fails because of b* functions. Linker can't=20
> find them later. At first gcc is complaining that b* functions=20
> are impilicity declared. Acording to man pages these functions=20
> are deprecated anyway.
> Patch is for Gentoo's iputils-20070202.
:

Applied, thanks.

--yoshfuji
