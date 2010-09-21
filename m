From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] iputils ping,ping6: use sig_atomic_t for flags set by
 signal handlers
Date: Tue, 21 Sep 2010 15:05:36 +0900
Message-ID: <4C984B30.6020204@linux-ipv6.org>
References: <alpine.DEB.1.10.1009051432540.13886@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:55916 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751008Ab0IUGG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 02:06:26 -0400
In-Reply-To: <alpine.DEB.1.10.1009051432540.13886@red.crap.retrofitta.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(2010/09/05 21:52), Thomas Habets wrote:
> 
> Required by ISO C99 7.14.1.1 paragraph 5.

Applied, thanks.

--yoshfuji
