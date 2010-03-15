From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TI DaVinci EMAC: Convert to dev_pm_ops
Date: Mon, 15 Mar 2010 15:48:06 -0700 (PDT)
Message-ID: <20100315.154806.253014581.davem@davemloft.net>
References: <1268296676-12514-1-git-send-email-chaithrika@ti.com>
	<87zl2d3ys0.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chaithrika@ti.com, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: khilman@deeprootsystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34490
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937010Ab0COWrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:47:45 -0400
In-Reply-To: <87zl2d3ys0.fsf@deeprootsystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hilman <khilman@deeprootsystems.com>
Date: Fri, 12 Mar 2010 15:28:47 -0800

> Chaithrika U S <chaithrika@ti.com> writes:
> 
>> Migrate from the legacy PM hooks to use dev_pm_ops structure.
>>
>> Signed-off-by: Chaithrika U S <chaithrika@ti.com>
> 
> Acked-by: Kevin Hilman <khilman@deeprootsystems.com>

Applied, thanks.
