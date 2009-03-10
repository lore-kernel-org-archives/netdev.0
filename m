From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/13] forcedeth: remove overhead
Date: Tue, 10 Mar 2009 05:30:52 -0700 (PDT)
Message-ID: <20090310.053052.134519963.davem@davemloft.net>
References: <49B0139E.6080109@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754881AbZCJMbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 08:31:06 -0400
In-Reply-To: <49B0139E.6080109@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Thu, 05 Mar 2009 13:02:06 -0500

> This patch removes unnecessary overhead code. Firstly, there is no nead to mask off unwanted interrupts as we will be checking against the irqmask field anyways. Secondly, there has been no value in last few years from detecting error or unknown interrupts.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Applied.
