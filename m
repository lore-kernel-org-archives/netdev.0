From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2: Update vlan_features
Date: Sun, 26 Jul 2009 19:50:22 -0700 (PDT)
Message-ID: <20090726.195022.118249297.davem@davemloft.net>
References: <4A685122.3090300@gmail.com>
	<20090723.105932.249439810.davem@davemloft.net>
	<1248394379.13301.2.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ogerlitz@voltaire.com, kaber@trash.net,
	fubar@us.ibm.com, netdev@vger.kernel.org, eilong@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56715
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755812AbZG0CuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 22:50:16 -0400
In-Reply-To: <1248394379.13301.2.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 23 Jul 2009 17:12:59 -0700

> 
> On Thu, 2009-07-23 at 10:59 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 23 Jul 2009 14:01:38 +0200
>> 
>> > [PATCH net-next-2.6] bnx2: Update vlan_features
>> > 
>> > In order to get full use of some advanced features of BNX2, we now need to
>> > fill dev->vlan_features.
>> > 
>> > Patch successfully tested with vlan devices built on top of bonding.
>> > (bond0 : one bnx2 slave, one tg3 slave (not yet vlan_features enabled)
>> > 
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> 
>> Can I get some Broadcom ACKs for this?
>> 
> I've reviewed and tested Eric's 2nd patch.  Thanks.
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied.
