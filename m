From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 16:39:09 -0700
Message-ID: <4FEB999D.20309@hp.com>
References: <4FEB7BB9.1080905@candelatech.com> <1340832947.26242.169.camel@edumazet-glaptop> <4FEB90C3.9050607@hp.com> <20120627.160922.686783180082355740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, greearb@candelatech.com,
	shemminger@vyatta.com, tparkin@katalix.com, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, jchapman@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:6088 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab2F0XjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 19:39:11 -0400
In-Reply-To: <20120627.160922.686783180082355740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2012 04:09 PM, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Wed, 27 Jun 2012 16:01:23 -0700
>
>> At 100 Gbit/s Ethernet, that is upwards of 147
>
> Listing upcoming technologies shows that you miss Eric's point.
>
> Nobody with a brain is going to drive those kinds of cards on boxes
> running 32-bit kernels.

Yes, I strayed from the context of 32-bit kernels.  I will go run iperf 
a couple times as penance :)

rick
