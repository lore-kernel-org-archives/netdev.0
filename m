From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/02 V3] net/ipv6: seperate sit driver to extra module
 (addrconf.c changes)
Date: Tue, 10 Oct 2006 14:50:17 -0700 (PDT)
Message-ID: <20061010.145017.40575796.davem@davemloft.net>
References: <20061010153745.GA27455@zlug.org>
	<20061010154355.GD27455@zlug.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33191
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030532AbWJJVuR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 17:50:17 -0400
To: joro-lkml@zlug.org
In-Reply-To: <20061010154355.GD27455@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joerg Roedel <joro-lkml@zlug.org>
Date: Tue, 10 Oct 2006 17:43:55 +0200

> This patch contains the changes to net/ipv6/addrconf.c to remove sit
> specific code if the sit driver is not selected.
> 
> Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks a lot.
