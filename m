From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: AIM9 regression
Date: Wed, 24 Sep 2008 09:20:17 -0500
Message-ID: <48DA4CA1.2000102@linux-foundation.org>
References: <20080923133616.7d51c953@extreme>	<48D95447.2010701@linux-foundation.org>	<48D995E8.1090802@garzik.org> <20080923.201132.247222254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, shemminger@vyatta.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44223 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751280AbYIXOWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 10:22:05 -0400
In-Reply-To: <20080923.201132.247222254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Tue, 23 Sep 2008 21:20:40 -0400
> 
>> Christoph Lameter wrote:
>>> Stephen Hemminger wrote:
>>>
>>>> Hardware configuration please?
>>> Dual Processor 4 core 8G, Xeon X5460  @ 3.16GHz, 667Mhz memory.
>> Network hardware configuration?
>>
>> Or is the TCP test over loopback?
> 
> I'm pretty sure it's over loopback :-)

Correct.

