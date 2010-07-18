From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bnx2: use device model DMA API
Date: Sun, 18 Jul 2010 14:43:16 -0700 (PDT)
Message-ID: <20100718.144316.209959291.davem@davemloft.net>
References: <20100715142530.12504.80404.send-patch@dhcp-lab-109.englab.brq.redhat.com>
	<20100715142544.12504.283.send-patch@dhcp-lab-109.englab.brq.redhat.com>
	<1279315759.18129.43.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52155
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757321Ab0GRVnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 17:43:02 -0400
In-Reply-To: <1279315759.18129.43.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 16 Jul 2010 14:29:19 -0700

> 
> On Thu, 2010-07-15 at 07:25 -0700, Stanislaw Gruszka wrote:
>> Use DMA API as PCI equivalents will be deprecated. This change also allow
>> to allocate with GFP_KERNEL in some places.
>> 
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied.
