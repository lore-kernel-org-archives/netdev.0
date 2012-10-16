From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/2] s390: network bug fixes for net
Date: Tue, 16 Oct 2012 14:42:41 -0400 (EDT)
Message-ID: <20121016.144241.1919888793645036212.davem@davemloft.net>
References: <20121016052116.210859505@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab2JPSmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 14:42:46 -0400
In-Reply-To: <20121016052116.210859505@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Tue, 16 Oct 2012 07:21:16 +0200

> Hi Dave,
> 
> here are some bug fixes for net.
> 
> shortlog:
> 
> Hendrik Brueckner (1)
> smsgiucv: reestablish IUCV path after resume
> 
> Stefan Raspl (1)
> qeth: fix deadlock between recovery and bonding driver

Both applied, thanks.
