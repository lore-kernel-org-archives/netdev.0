From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Changes to use only priority
 codes allowed by f/w
Date: Thu, 21 Oct 2010 07:14:57 -0700 (PDT)
Message-ID: <20101021.071457.193709398.davem@davemloft.net>
References: <20101021134109.GA3195@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48897
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932252Ab0JUOOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 10:14:37 -0400
In-Reply-To: <20101021134109.GA3195@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 21 Oct 2010 19:11:09 +0530

> Changes to use one of the priority codes allowed by CNA f/w for NIC traffic
> from host. The driver gets the bit map of the priority codes allowed for
> host traffic through a asynchronous message from the f/w that the driver
> subscribes to.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
