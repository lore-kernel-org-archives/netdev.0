From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC v2 3/7] net: netfilter conntrack - add per-net functionality
 for SCTP protocol
Date: Thu, 12 Mar 2009 10:03:20 +0100
Message-ID: <49B8CFD8.6030403@free.fr>
References: <20090311205706.141086138@gmail.com> <20090311210817.384140456@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, xemul@openvz.org,
	adobriyan@gmail.com, Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:39914 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbZCLJEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 05:04:23 -0400
In-Reply-To: <20090311210817.384140456@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyrill Gorcunov wrote:
> Module specific data moved into per-net site and being allocated/freed
> during net namespace creation/deletion.
>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
>   
Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
