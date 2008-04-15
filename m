From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 6/10][VLAN]: Create proc entries in the proper
 net.
Date: Tue, 15 Apr 2008 14:28:08 +0200
Message-ID: <48049F58.1030307@trash.net>
References: <4804989F.1060503@openvz.org> <48049B95.6010403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35685 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbYDOM2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:28:17 -0400
In-Reply-To: <48049B95.6010403@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> The proc_vlan_dir and proc_vlan_conf migrate on the struct
> vlan_net and their creation uses the struct net.
> 
> The devices' entries use the corresponding device's net.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Patrick McHardy <kaber@trash.net>
