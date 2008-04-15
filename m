From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 4/10][VLAN]: Introduce the vlan_net structure
 and init/exit net ops.
Date: Tue, 15 Apr 2008 14:24:01 +0200
Message-ID: <48049E61.1060100@trash.net>
References: <4804989F.1060503@openvz.org> <48049A71.1030900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35617 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbYDOMYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:24:20 -0400
In-Reply-To: <48049A71.1030900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Unlike TUN, it is empty from the very beginning, and will 
> be eventually populated later.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Patrick McHardy <kaber@trash.net>
