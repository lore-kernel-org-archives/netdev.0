From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] netfilter: Resolve missing-field-initializers
 warnings
Date: Mon, 28 Jul 2014 17:21:26 -0700 (PDT)
Message-ID: <20140728.172126.54318998043857924.davem@davemloft.net>
References: <1406279936-6494-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbaG2AV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 20:21:27 -0400
In-Reply-To: <1406279936-6494-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 25 Jul 2014 02:18:56 -0700

> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> Resolve missing-field-initializers warnings by avoiding
> implicit inner field initializer. The more explicit form
> avoids the warning.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Likewise please submit this properly to the netfilter maintainers.
