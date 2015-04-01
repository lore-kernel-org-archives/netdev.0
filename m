From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] crypto: algif - use kmalloc instead of kzalloc
Date: Wed, 01 Apr 2015 15:33:06 -0400 (EDT)
Message-ID: <20150401.153306.1018888107007248799.davem@davemloft.net>
References: <20150330212543.7179.25983.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	herbert@gondor.apana.org.au
To: tadeusz.struk@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbbDATdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 15:33:09 -0400
In-Reply-To: <20150330212543.7179.25983.stgit@tstruk-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tadeusz Struk <tadeusz.struk@intel.com>
Date: Mon, 30 Mar 2015 14:25:44 -0700

> No need to use kzalloc to allocate sgls as the structure is initialized anyway.
> 
> Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>

Applied.
