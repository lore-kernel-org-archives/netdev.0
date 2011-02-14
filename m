From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 1/4] rtnetlink: implement setting of
 master device
Date: Sun, 13 Feb 2011 16:58:47 -0800 (PST)
Message-ID: <20110213.165847.108798056.davem@davemloft.net>
References: <4D583467.6020803@trash.net>
	<20110213201536.GH2740@psychotron.redhat.com>
	<4D583C2F.7070308@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58692
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755316Ab1BNA6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 19:58:11 -0500
In-Reply-To: <4D583C2F.7070308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 13 Feb 2011 21:16:47 +0100

> Am 13.02.2011 21:15, schrieb Jiri Pirko:
>> Subject: [patch net-next-2.6 1/4] rtnetlink: implement setting of master device
>> 
>> This patch allows userspace to enslave/release slave devices via netlink
>> interface using IFLA_MASTER. This introduces generic way to add/remove
>> underling devices.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied.
