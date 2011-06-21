From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP new-reno support?
Date: Tue, 21 Jun 2011 09:35:04 -0700
Message-ID: <4E00C838.70706@candelatech.com>
References: <4E00BDAB.1040309@candelatech.com> <A6200100-A147-481C-8230-9782822EA1F7@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43958 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756881Ab1FUQfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 12:35:08 -0400
In-Reply-To: <A6200100-A147-481C-8230-9782822EA1F7@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2011 09:32 AM, Alexander Zimmermann wrote:
> Hi,
>
> Am 21.06.2011 um 17:50 schrieb Ben Greear:
>
>> I see a large number of TCP congestion algorithms supported, but
>> nothing that explicitly says newreno.
>
> It's implicit :-)
>
>>   Is it actually supported?
>
> tcp_congestion_control=reno
> tcp_dsack=0
> tcp_fack=0
> tcp_sack=0
> tcp_frto=0
>
> then, you get NewReno. And, yes, it's not possible to get Reno

Thanks!

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

