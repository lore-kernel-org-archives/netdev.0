From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] xen/netback: Add module alias for autoloading
Date: Thu, 30 Jun 2011 11:19:51 -0700 (PDT)
Message-ID: <20110630.111951.1084304206576075172.davem@davemloft.net>
References: <20110629124132.GD31038@wavehammer.waldi.eu.org>
	<20110630163954.GE5771@dumpdata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: waldi@debian.org, xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org, axboe@kernel.dk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: konrad.wilk@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730Ab1F3SUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 14:20:16 -0400
In-Reply-To: <20110630163954.GE5771@dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Thu, 30 Jun 2011 12:39:54 -0400

> On Wed, Jun 29, 2011 at 02:41:32PM +0200, Bastian Blank wrote:
>> Add xen-backend:vif module alias to the xen-netback module. This allows
>> automatic loading of the module.
> 
> Dave,
> 
> Could you queue this up for 3.1 please? I've the other two patches in my
> tree for 3.1 and the block patch ready for Jens.

Done.
