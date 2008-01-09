From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Thu, 10 Jan 2008 01:40:51 +0900 (JST)
Message-ID: <20080110.014051.121940744.yoshfuji@linux-ipv6.org>
References: <20080109153656.GA16962@pingi.kke.suse.de>
	<20080110.013857.37616214.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34735 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbYAIQks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 11:40:48 -0500
In-Reply-To: <20080110.013857.37616214.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080110.013857.37616214.yoshfuji@linux-ipv6.org> (at Thu, 10 Jan 2008 01:38:57 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> - we could have "dad_reaction" interface variable and
>  > 1: disable interface
>  = 1: disable IPv6
>  < 0: ignore (as we do now)

Argh, >0, 0 and <0, maybe.

--yoshfuji
