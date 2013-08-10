From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: Fix inverted check in
 ndo_dflt_fdb_del()
Date: Sat, 10 Aug 2013 01:24:46 -0700 (PDT)
Message-ID: <20130810.012446.1274185214611315112.davem@davemloft.net>
References: <1376000389.22896.34.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968419Ab3HJIYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 04:24:46 -0400
In-Reply-To: <1376000389.22896.34.camel@sridhar.usor.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 08 Aug 2013 15:19:48 -0700

> Fix inverted check when deleting an fdb entry.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

This fixes a bug that has been around for a release or two, so I've
applied it to 'net'.

Thanks.
