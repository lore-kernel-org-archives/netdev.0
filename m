From: David Miller <davem@davemloft.net>
Subject: Re: [patch 00/13] s390: network patches for net-next
Date: Sat, 13 Aug 2011 01:10:38 -0700 (PDT)
Message-ID: <20110813.011038.384530492272203270.davem@davemloft.net>
References: <20110808113346.516293249@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab1HMILm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 04:11:42 -0400
In-Reply-To: <20110808113346.516293249@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Mon, 08 Aug 2011 13:33:46 +0200

> Einar Lueck (4)
> qdio: support asynchronous delivery of storage blocks
> qdio: support forced signal adapter indications
> qeth: exploit asynchronous delivery of storage blocks
> qeth: support forced signal adapter indications
> 
> Ursula Braun (3)
> iucv: kernel option for z/VM IUCV and HiperSockets
> af_iucv: cleanup - use iucv_sk(sk) early
> af_iucv: add HiperSockets transport
> 
> Frank Blaschka (4)
> iucv: introduce loadable iucv interface
> af_iucv: use loadable iucv interface
> if_ether: add new Ethernet Protocol ID for af_iucv
> qeth: add support for af_iucv HiperSockets transport

All applied to net-next, thanks.
