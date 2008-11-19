From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 0/3] net: RCU lookups for UDP, DCCP and TCP protocol
Date: Wed, 19 Nov 2008 13:52:05 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0811191351340.23774@quilx.com>
References: <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com>
 <491C27F0.8000507@cosmosbay.com> <20081116.194146.35091404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dada1@cosmosbay.com, paulmck@linux.vnet.ibm.com, minyard@acm.org,
	shemminger@vyatta.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org, a.p.zijlstra@chello.nl, zbr@ioremap.net,
	christian@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi025.sbcis.sbc.com ([207.115.36.54]:36160 "EHLO
	nlpi025.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbYKSTw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 14:52:56 -0500
In-Reply-To: <20081116.194146.35091404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Nov 2008, David Miller wrote:

> These patches are incredibly cool!

How much does this give us on the aim9 udp test?
