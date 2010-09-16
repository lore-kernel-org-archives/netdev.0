From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Remove a silly return
Date: Wed, 15 Sep 2010 22:29:46 -0700 (PDT)
Message-ID: <20100915.222946.209980503.davem@davemloft.net>
References: <1284609262-8653-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58975
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752329Ab0IPF31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 01:29:27 -0400
In-Reply-To: <1284609262-8653-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Thu, 16 Sep 2010 00:54:22 -0300

> This patch removes the unconditional return in the end of the
> function check_sqs()
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied.
