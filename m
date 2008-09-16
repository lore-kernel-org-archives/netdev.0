From: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
Subject: Re: [PATCH] cs89x0: add support for i.MX31ADS ARM board
Date: Tue, 16 Sep 2008 14:54:54 +0200
Message-ID: <48CFAC9E.5000906@xenomai.org>
References: <489DD049.6020106@xenomai.org> <48CC5B03.2020003@garzik.org> <20080914120358.GA26748@xi.wantstofly.org> <48CD1C19.60803@xenomai.org> <20080916124422.GC18556@xi.wantstofly.org> <48CFAAE5.80805@xenomai.org> <20080916125228.GA19104@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Russell King <rmk@arm.linux.org.uk>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenomai.org ([88.191.250.36]:39173 "EHLO xenomai.fsffrance.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbYIPMy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 08:54:57 -0400
In-Reply-To: <20080916125228.GA19104@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
>>>> Hi Lennert,
>>>>
>>>> When I published this patch, I had access to an i.MX31ADS board, and
>>>> getting Linux to work on this board was just a necessity to get my job
>>>> done. I did this by copying the parts I needed working (the serial
>>>> console and ethernet driver) from the Freescale tree.
>>>>
>>>> Now, I am no longer working on this, so I can not test any modification.
>>>> And I do not even know why people at Freescale did what they did.
>>> I guess then we should just wait until the Freescale people submit it.
>> I will be able to test the modification soon. I will repost the patch on
>> linux-arm-kernel after this test.
> 
> OK.  Please also try leaving reset_chip() as it is and see if it still
> works like that -- I suspect that that part of the patch might have been
> a debug leftover.

Yes, that is precisely the part I want to test.

-- 
                                                 Gilles.
