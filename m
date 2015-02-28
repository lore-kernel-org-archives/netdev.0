From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/4] Revert "sh_eth: Enable Rx descriptor word 0
 shift for r8a7790"
Date: Sat, 28 Feb 2015 14:47:44 -0500 (EST)
Message-ID: <20150228.144744.744392539789358424.davem@davemloft.net>
References: <54EF7163.80900@cogentembedded.com>
	<1424981623.4444.65.camel@xylophone.i.decadent.org.uk>
	<54EF8380.3030903@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.hutchings@codethink.co.uk, netdev@vger.kernel.org,
	linux-kernel@lists.codethink.co.uk,
	nobuhiro.iwamatsu.yj@renesas.com, mitsuhiro.kimura.kc@renesas.com,
	ykaneko0929@gmail.com, yoshihiro.shimoda.uh@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbbB1Trr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 14:47:47 -0500
In-Reply-To: <54EF8380.3030903@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 26 Feb 2015 23:35:12 +0300

> On 02/26/2015 11:13 PM, Ben Hutchings wrote:
>> Well, it's logically a revert.  I could mention that I'm also fixing a
>> comment to match.
> 
>    Yes, please.

Ok, then I'm waiting for a respin of this series.
