From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dl2k: nulify fraginfo after unmap
Date: Thu, 27 Jan 2011 14:24:20 -0800 (PST)
Message-ID: <20110127.142420.48502291.davem@davemloft.net>
References: <20110126104521.GA2431@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56499
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753692Ab1A0WXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 17:23:45 -0500
In-Reply-To: <20110126104521.GA2431@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Wed, 26 Jan 2011 11:45:42 +0100

> Patch fixes: "DMA-API: device driver tries to free an invalid DMA
> memory address" warning reported here:
> https://bugzilla.redhat.com/show_bug.cgi?id=639824
> 
> Reported-by: Frantisek Hanzlik <franta@hanzlici.cz>
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Applied.
