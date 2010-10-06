From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ehea: converting msleeps to waitqueue on
 check_sqs() function
Date: Tue, 05 Oct 2010 20:15:01 -0700 (PDT)
Message-ID: <20101005.201501.112592302.davem@davemloft.net>
References: <1286320583-5594-1-git-send-email-leitao@linux.vnet.ibm.com>
	<1286320583-5594-2-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48147
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758540Ab0JFDOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:14:40 -0400
In-Reply-To: <1286320583-5594-2-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Tue,  5 Oct 2010 19:16:23 -0400

> Removing the msleep() call in check_sqs() function, and replacing by a wait queue.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied.
