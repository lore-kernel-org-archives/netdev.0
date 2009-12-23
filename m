From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 3/4] netxen: support pci error handlers
Date: Wed, 23 Dec 2009 14:15:32 -0800 (PST)
Message-ID: <20091223.141532.104070303.davem@davemloft.net>
References: <1260340857-11487-1-git-send-email-amit.salecha@qlogic.com>
	<1260340857-11487-4-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757400AbZLWWPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 17:15:31 -0500
In-Reply-To: <1260340857-11487-4-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Tue,  8 Dec 2009 22:40:56 -0800

> o Support pci error detection and recovery.
> o Refactor suspend and resume code, to share with io_error_detected,
>   and slot_reset callbacks
> o NX_NEED_AER device state added, to synchronize with firmware
>   recovery.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
