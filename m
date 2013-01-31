From: Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com>
Subject: Re: [PATCH] net/cadence: don't build by default
Date: Thu, 31 Jan 2013 20:03:08 +0100
Message-ID: <510ABFEC.30801@gmail.com>
References: <1359656815-27919-1-git-send-email-riccardo.magliocchetti@gmail.com> <20130131.135723.1501528815124767623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:48138 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3AaTDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 14:03:10 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so1726106eei.21
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 11:03:09 -0800 (PST)
In-Reply-To: <20130131.135723.1501528815124767623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 31/01/2013 19:57, David Miller ha scritto:
> From: Riccardo Magliocchetti<riccardo.magliocchetti@gmail.com>
> Date: Thu, 31 Jan 2013 19:26:55 +0100
>
>> No need to build net/cadence driver by default.
>>
>> Signed-off-by: Riccardo Magliocchetti<riccardo.magliocchetti@gmail.com>
>
> Vendor guards are set yes on purpose, because it mimicks for compatability
> the behavior that existed before the vendor guards were in place.
>
> These checks guard families of drivers from being offered, rather than
> the drivers themselves.
>
> I'm not applying this patch.

Indeed, seen the default Y during make oldconfig and overreacted. Sorry 
for the noise.

riccardo
