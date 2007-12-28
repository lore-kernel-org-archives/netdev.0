From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net/ipv4/netfilter/ip_tables.c: remove some inlines
Date: Fri, 28 Dec 2007 16:30:36 +0100
Message-ID: <4775169C.8040302@trash.net>
References: <200712161247.53986.vda.linux@googlemail.com> <47668BE9.8010504@trash.net> <200712270401.35983.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32839 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbXL1Pau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 10:30:50 -0500
In-Reply-To: <200712270401.35983.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Vlasenko wrote:
> On Monday 17 December 2007 14:47, Patrick McHardy wrote:
>   
>> This clashes with my pending patches, which I'll push upstream
>> today. I also spent some time resyncing ip_tables and ip6_tables
>> so a diff of both (with some sed'ing) shows only the actual
>> differences, so please update ip6_tables as well.
>>     
>
> I would be happy to rediff the patch.
>
> Which tree should I sync against in order to not collide
> with your changes?
>   

The net-2.6.25.git tree contains all my changes.
