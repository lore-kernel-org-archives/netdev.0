From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Document /proc/sys/net/core/netdev_budget
Date: Wed, 18 Mar 2009 18:51:13 -0700 (PDT)
Message-ID: <20090318.185113.256379588.davem@davemloft.net>
References: <20090316133633.2df4ed3e@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60966
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754913AbZCSBv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:51:26 -0400
In-Reply-To: <20090316133633.2df4ed3e@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Mon, 16 Mar 2009 13:36:33 +0100

> The NAPI poll parameter netdev_budget is not documented in kernel-docs. Since
> it may have a substantial effect on at least some network loads, it should be.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com> 

Applied, thanks.
