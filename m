From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 2/6] netlink: add nla_policy_len()
Date: Wed, 25 Mar 2009 18:27:31 +0100
Message-ID: <49CA6983.6050304@trash.net>
References: <20090316220659.756862181@jonathan.eitzenberger.org> <20090316221137.034320718@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Holger Eitzenberger <holger@eitzenberger.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35359 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754885AbZCYR1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 13:27:38 -0400
In-Reply-To: <20090316221137.034320718@jonathan.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holger Eitzenberger wrote:
> It calculates the max. length of a Netlink policy, which is usefull
> for allocating Netlink buffers roughly the size of the actual
> message.

Applied, thanks.
