From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next-2.6] bnx2: Update vlan_features
Date: Thu, 23 Jul 2009 17:12:59 -0700
Message-ID: <1248394379.13301.2.camel@HP1>
References: <4A681029.4070600@voltaire.com> <4A681F63.7060001@gmail.com>
 <4A685122.3090300@gmail.com>
 <20090723.105932.249439810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"ogerlitz@voltaire.com" <ogerlitz@voltaire.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3313 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbZGXAUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2009 20:20:44 -0400
In-Reply-To: <20090723.105932.249439810.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2009-07-23 at 10:59 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 23 Jul 2009 14:01:38 +0200
> 
> > [PATCH net-next-2.6] bnx2: Update vlan_features
> > 
> > In order to get full use of some advanced features of BNX2, we now need to
> > fill dev->vlan_features.
> > 
> > Patch successfully tested with vlan devices built on top of bonding.
> > (bond0 : one bnx2 slave, one tg3 slave (not yet vlan_features enabled)
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Can I get some Broadcom ACKs for this?
> 
I've reviewed and tested Eric's 2nd patch.  Thanks.

Acked-by: Michael Chan <mchan@broadcom.com>


