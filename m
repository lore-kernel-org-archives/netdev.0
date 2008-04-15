From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 7/10][VLAN]: Make the /proc/net/vlan/conf file
 show per-net info.
Date: Tue, 15 Apr 2008 14:28:45 +0200
Message-ID: <48049F7D.1040707@trash.net>
References: <4804989F.1060503@openvz.org> <48049BF1.5000600@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35701 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbYDOM27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:28:59 -0400
In-Reply-To: <48049BF1.5000600@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> It is created in a proper net, so make is show info, related
> to this particular net.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Patrick McHardy <kaber@trash.net>
