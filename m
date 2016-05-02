From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2 bluetooth-next 02/10] 6lowpan: add 802.15.4 short addr
 slaac
Date: Mon, 2 May 2016 21:06:26 +0200
Message-ID: <0924d341-f27b-227a-a07d-19b272fad6fa@stressinduktion.org>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-3-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59154 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754690AbcEBTGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 15:06:32 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 75E2E20CE5
	for <netdev@vger.kernel.org>; Mon,  2 May 2016 15:06:31 -0400 (EDT)
In-Reply-To: <1461140382-4784-3-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.04.2016 10:19, Alexander Aring wrote:
> This patch adds the autoconfiguration if a valid 802.15.4 short address
> is available for 802.15.4 6LoWPAN interfaces.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
