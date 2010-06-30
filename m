From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/3] vmxnet3: Remove incorrect
 implementation of ethtool_ops::get_flags()
Date: Wed, 30 Jun 2010 14:10:39 -0700 (PDT)
Message-ID: <20100630.141039.233873934.davem@davemloft.net>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
	<1277902060.2082.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com,
	pv-drivers@vmware.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756678Ab0F3VKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 17:10:25 -0400
In-Reply-To: <1277902060.2082.13.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Jun 2010 13:47:40 +0100

> Only some netdev feature flags correspond directly to ethtool feature
> flags.  ethtool_op_get_flags() does the right thing.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
