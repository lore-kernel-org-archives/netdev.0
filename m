From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 10/10][VLAN]: Handle vlan devices net namespace
 changing.
Date: Tue, 15 Apr 2008 14:30:20 +0200
Message-ID: <48049FDC.3010506@trash.net>
References: <4804989F.1060503@openvz.org> <48049D45.5020606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35725 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbYDOMa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:30:29 -0400
In-Reply-To: <48049D45.5020606@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> When van device is moved to another namespace proc files,
> related to this device, should also change one.
> 
> Use the netdev REGISTER and UNREGISTER event handlers for this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

For patches 8-10 also:

Acked-by: Patrick McHardy <kaber@trash.net>

