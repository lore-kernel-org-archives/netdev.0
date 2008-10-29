From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 11:20:19 -0700 (PDT)
Message-ID: <20081029.112019.193770845.davem@davemloft.net>
References: <49082718.2030201@cosmosbay.com>
	<4908627C.6030001@acm.org>
	<490874F2.2060306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: minyard@acm.org, shemminger@vyatta.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48511
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752020AbYJ2SUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:20:45 -0400
In-Reply-To: <490874F2.2060306@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 29 Oct 2008 15:36:34 +0100

> [PATCH] udp: introduce sk_for_each_rcu_safenext()

Also applied, thanks Eric.
