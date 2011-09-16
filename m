From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Fri, 16 Sep 2011 19:35:29 -0400 (EDT)
Message-ID: <20110916.193529.1252147879675316417.davem@davemloft.net>
References: <1315340388.3400.28.camel@edumazet-laptop>
	<CAAM7YAnqLyK6JWPW_Y8wD=ykqWMn4fPdJ3_7yUUB+TQZWfDJzQ@mail.gmail.com>
	<1315364126.3400.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zheng.z.yan@linux.intel.com, tim.c.chen@linux.intel.com,
	zheng.z.yan@intel.com, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, jirislaby@gmail.com, sedat.dilek@gmail.com,
	alex.shi@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291Ab1IPXhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 19:37:39 -0400
In-Reply-To: <1315364126.3400.64.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Sep 2011 04:55:26 +0200

> Please David just revert 0856a304091b33a8e

Done.
