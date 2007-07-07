From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Fix handling of IPv6 RH with 0 segments left
Date: Sat, 07 Jul 2007 23:37:17 +0900 (JST)
Message-ID: <20070707.233717.34364251.yoshfuji@linux-ipv6.org>
References: <200707071735.00366@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: rdenis@simphalempin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47626 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbXGGOgo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 10:36:44 -0400
In-Reply-To: <200707071735.00366@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200707071735.00366@auguste.remlab.net> (at Sat, 7 Jul 2007 =
17:34:59 +0300), R=E9mi Denis-Courmont <rdenis@simphalempin.com> says:

> Fix handling of IPv6 Routing Headers with zero segments left.
> In that case, we should ignore the extension header and continue with
> the next one, rather than return a Paramater Problem.

Remi, patch is already available.

--yoshfuji
