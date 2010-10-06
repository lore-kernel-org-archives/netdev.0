From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ehea: using wait queues instead of msleep on
 ehea_flush_sq
Date: Tue, 05 Oct 2010 20:14:54 -0700 (PDT)
Message-ID: <20101005.201454.189694650.davem@davemloft.net>
References: <1286320583-5594-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48143
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758400Ab0JFDOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:14:33 -0400
In-Reply-To: <1286320583-5594-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Tue,  5 Oct 2010 19:16:22 -0400

> This patch just remove a msleep loop and change to wait queue,
> making the code cleaner.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Acked-by: David Howells <dhowells@redhat.com>

Applied.
