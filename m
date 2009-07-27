From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 01/12] netxen: refresh firmware info after reset
Date: Mon, 27 Jul 2009 10:33:32 -0700 (PDT)
Message-ID: <20090727.103332.141925624.davem@davemloft.net>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
	<1248674867-18821-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49812
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753026AbZG0RdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 13:33:25 -0400
In-Reply-To: <1248674867-18821-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 26 Jul 2009 23:07:36 -0700

> o move dma mask update to netxen_start_firmware() so that
>   if firmware changes across suspend (e.g. file -> flash)
>   it reflects right dma mask.
> o re-read firmware capabilities after firmware reset.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
