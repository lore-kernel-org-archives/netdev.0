From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG: 3.13.0-rc4] inconsistent lock state
Date: Tue, 17 Dec 2013 10:59:41 -0800
Message-ID: <1387306781.19078.288.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52B09446.7060809@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Knut Petersen <Knut_Petersen@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f180.google.com ([209.85.161.180]:60833 "EHLO
	mail-gg0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab3LQS7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 13:59:48 -0500
In-Reply-To: <52B09446.7060809@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 19:13 +0100, Knut Petersen wrote:
> Hi Linus / everybody!
> 
> Booting openSuSE 13.1 with kernel 3.13.0-rc4 triggers the attached
> warning.
> 
> cu,
>   Knut
> 
> 

Following patch should solve the issue.

http://patchwork.ozlabs.org/patch/301382/

Sorry for this ...

Thanks
