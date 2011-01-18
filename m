From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 resend] netfilter: remove an atomic bit operation
Date: Tue, 18 Jan 2011 15:08:41 +0100
Message-ID: <4D359EE9.5070203@trash.net>
References: <1295090580-14472-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Tim Gardner <tim.gardner@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56289 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab1AROIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 09:08:42 -0500
In-Reply-To: <1295090580-14472-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.01.2011 12:23, Changli Gao wrote:
> As this ct won't be seen by the others, we don't need to set the
> IPS_CONFIRMED_BIT in atomic way.
> 

Applied, thanks.
