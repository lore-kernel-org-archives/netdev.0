From: David Newall <davidn@davidnewall.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Sat, 17 May 2014 00:53:08 +0930
Message-ID: <53762D5C.3090305@davidnewall.com>
References: <536F8C0F.4090206@davidnewall.com>	,<5370CB47.4010400@davidnewall.com>	 <DUB123-W514EA0A4A29F520778F2FFED350@phx.gbl>	 <53715D67.8020803@davidnewall.com> <53736ACC.9010902@davidnewall.com>	 <537621AC.1060409@davidnewall.com> <1400253599.7973.181.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lukas Tribus <luky-37@hotmail.com>,
	Netdev <netdev@vger.kernel.org>, "fw@strlen.de" <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:36282 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932612AbaEPPXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:23:10 -0400
In-Reply-To: <1400253599.7973.181.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/05/14 00:49, Eric Dumazet wrote:
> Is this meant to be an official patch ?

No.  I anticipate there will be discussion before we reach an official 
patch.
> Please
>
> 1) CC patch author (Bandan Das<bandan.das@stratus.com>) so he has a way
> to comment if he no longer follows netdev ?

His email bounces.
