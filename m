From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 2/10][RTNL]: Introduce the rtnl_kill_links
 helper.
Date: Tue, 15 Apr 2008 14:01:39 +0200
Message-ID: <48049923.90601@trash.net>
References: <4804989F.1060503@openvz.org> <48049994.7050405@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35247 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbYDOMBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:01:44 -0400
In-Reply-To: <48049994.7050405@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> This one is responsible for calling ->dellink on each net
> device found in net to help with vlan net_exit hook in the
> nearest future.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Patrick McHardy <kaber@trash.net>
