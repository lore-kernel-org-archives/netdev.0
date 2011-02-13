From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next-2.6 1/4] rtnetlink: implement setting of master
 device
Date: Sun, 13 Feb 2011 21:16:47 +0100
Message-ID: <4D583C2F.7070308@trash.net>
References: <20110213193105.GD2740@psychotron.redhat.com> <4D583467.6020803@trash.net> <20110213201536.GH2740@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39391 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815Ab1BMURD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 15:17:03 -0500
In-Reply-To: <20110213201536.GH2740@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 13.02.2011 21:15, schrieb Jiri Pirko:
> Subject: [patch net-next-2.6 1/4] rtnetlink: implement setting of master device
> 
> This patch allows userspace to enslave/release slave devices via netlink
> interface using IFLA_MASTER. This introduces generic way to add/remove
> underling devices.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Acked-by: Patrick McHardy <kaber@trash.net>
