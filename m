From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 2/4] netxen: fix tx timeout recovery
Date: Wed, 23 Dec 2009 14:15:23 -0800 (PST)
Message-ID: <20091223.141523.71127928.davem@davemloft.net>
References: <1260340857-11487-1-git-send-email-amit.salecha@qlogic.com>
	<1260340857-11487-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42904
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757404AbZLWWPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 17:15:21 -0500
In-Reply-To: <1260340857-11487-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Tue,  8 Dec 2009 22:40:55 -0800

> o In case of tx timeout, firmare may be healthy, but some pci-func may
>   see no response from it. Force firmware reset, if some pci-func
>   explicitly requests so.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
