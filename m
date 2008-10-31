From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: Introduce special NULL pointers for hlist
 termination
Date: Fri, 31 Oct 2008 00:51:31 -0700 (PDT)
Message-ID: <20081031.005131.158229955.davem@davemloft.net>
References: <4909D551.9080309@cosmosbay.com>
	<20081030085126.0d9b956b@extreme>
	<4909EAE3.9060002@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, paulmck@linux.vnet.ibm.com, minyard@acm.org,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38776
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752311AbYJaHv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 03:51:57 -0400
In-Reply-To: <4909EAE3.9060002@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 30 Oct 2008 18:12:03 +0100

> More seriously Stephen, if the infrastructure is clean, and well
> tested on a relative simple case (UDP), it can then be deployed on a
> much more interesting protocol : TCP

I'm really looking forward to someone finally tackling that problem :)

> The moment we switch to RCU, we have to accept the pain of really
> understand what we did. Details are scary yes.

Agreed.
