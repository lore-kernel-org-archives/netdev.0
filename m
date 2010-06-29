From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] vmxnet3: fail when try to setup unsupported
 features
Date: Tue, 29 Jun 2010 00:55:41 -0700 (PDT)
Message-ID: <20100629.005541.123992810.davem@davemloft.net>
References: <20100628112942.0c919746@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com, sbhatewara@vmware.com
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40823
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753966Ab0F2Hz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 03:55:27 -0400
In-Reply-To: <20100628112942.0c919746@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Mon, 28 Jun 2010 11:29:42 +0200

> Return EOPNOTSUPP in ethtool_ops->set_flags.
> 
> Fix coding style while at it.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Applied.
