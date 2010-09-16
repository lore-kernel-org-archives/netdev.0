From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 resend] nf_nat: no IP_NAT_RANGE_MAP_IPS flags when
 alloc_null_binding()
Date: Thu, 16 Sep 2010 19:48:20 +0200
Message-ID: <4C925864.5080806@trash.net>
References: <1282029898-3071-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49302 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755827Ab0IPRsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 13:48:21 -0400
In-Reply-To: <1282029898-3071-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.08.2010 09:24, Changli Gao wrote:
> When alloc_null_binding(), no IP_NAT_RNAGE_MAP_IPS in flags means no IP address
> translation is needed. It isn't necessary to specify the address explicitly.
> 

Applied.
