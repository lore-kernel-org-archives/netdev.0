From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPV6]: bug 10437: MSG_ERRQUEUE messages do not pass
 to connected raw sockets
Date: Fri, 11 Apr 2008 20:12:01 +0900 (JST)
Message-ID: <20080411.201201.91849801.yoshfuji@linux-ipv6.org>
References: <bug-10437-10286@http.bugzilla.kernel.org/>
	<20080410103444.d7309e1f.akpm@linux-foundation.org>
	<47FF455C.2070205@odu.neva.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: buc@odusz.so-cdu.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33323 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759037AbYDKLKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 07:10:16 -0400
In-Reply-To: <47FF455C.2070205@odu.neva.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47FF455C.2070205@odu.neva.ru> (at Fri, 11 Apr 2008 15:02:52 +0400), Dmitry Butskoy <buc@odusz.so-cdu.ru> says:

> Andrew Morton wrote:
> > Dmitry, I'd suggest that you send the patch via email to
> > netdev@vger.kernel.org 
> 
> OK, resend
> 
> > and to YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>.
> >   
> It seems that I cannot reach this e-mail address from my country :( (some terrible antispam?)
> 
> 
> 
> The small patch to fix bug #10437 .
> 
> See description of the bug at 
> http://bugzilla.kernel.org/show_bug.cgi?id=10437

I'm going to agree.

Your patch is for 2.6.24-stable
Can you provide patches for linux-2.6.25-rc, please?

Thanks.

--yoshfuji
