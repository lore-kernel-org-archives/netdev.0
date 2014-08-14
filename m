From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: ethernet: ibm: ehea: Remove duplicate object from
 Makefile
Date: Thu, 14 Aug 2014 14:40:03 -0700 (PDT)
Message-ID: <20140814.144003.1482528643881361535.davem@redhat.com>
References: <1408019183-5709-1-git-send-email-rupran@einserver.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org
To: rupran@einserver.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932176AbaHNVkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:40:09 -0400
In-Reply-To: <1408019183-5709-1-git-send-email-rupran@einserver.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Ruprecht <rupran@einserver.de>
Date: Thu, 14 Aug 2014 14:26:23 +0200

> In the Makefile, ehea_phyp.o is included twice in the list of
> object files compile into ehea.o.
> 
> This change removes one instance.
> 
> Signed-off-by: Andreas Ruprecht <rupran@einserver.de>

Applied.
