From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] bonding: fix broken multicast with round-robin
 mode
Date: Wed, 31 Mar 2010 14:25:43 -0700 (PDT)
Message-ID: <20100331.142543.32751372.davem@davemloft.net>
References: <1270048448.2103.28.camel@edumazet-laptop>
	<20100331.140055.246389406.davem@davemloft.net>
	<1270070586.2593.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org, lhh@redhat.com,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932241Ab0CaVZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 17:25:42 -0400
In-Reply-To: <1270070586.2593.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 31 Mar 2010 23:23:06 +0200

> New compiler got these new options :  -Wframe-larger-than=1024
> -fno-strict-overflow -fno-dwarf2-cfi-asm -fconserve-stack

Ok, so much for my warning option theory :-)
