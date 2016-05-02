From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2 bluetooth-next 03/10] 6lowpan: remove ipv6 module
 request
Date: Mon, 2 May 2016 21:06:59 +0200
Message-ID: <95742016-d41a-c62b-d77a-ea35671be931@stressinduktion.org>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-4-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59828 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754885AbcEBTHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 15:07:04 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 2809420AC0
	for <netdev@vger.kernel.org>; Mon,  2 May 2016 15:07:03 -0400 (EDT)
In-Reply-To: <1461140382-4784-4-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.04.2016 10:19, Alexander Aring wrote:
> Since we use exported function from ipv6 kernel module we don't need to
> request the module anymore to have ipv6 functionality.
> 
> Signed-off-by: Alexander Aring <aar@pengutronix.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
