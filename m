From: =?ISO-8859-1?Q?Richard_R=F6jfors?= <richard.rojfors@pelagicore.com>
Subject: Re: [PATCH] ks8842: Support 100Mbps when accessed via timberdale
Date: Mon, 26 Jul 2010 10:44:53 +0200
Message-ID: <4C4D4B05.8030501@pelagicore.com>
References: <1280091327.17191.8.camel@debian> <20100725.170327.226755551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw11.han.skanova.net ([81.236.55.20]:47181 "EHLO
	smtp-gw11.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab0GZIo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 04:44:57 -0400
In-Reply-To: <20100725.170327.226755551.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2010 02:03 AM, David Miller wrote:
>
> I'm not applying this patch, flow control is important and
> should be enabled by default whenever possible.  Please
> instead go try and figure out if flow control trigger
> points or RX/TX ring sizes need adjustment instead.

I agree, I will look at the flow control.

--Richard
