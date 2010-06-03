From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] fec: convert TX hook to netdev_tx_t
Date: Thu, 03 Jun 2010 03:19:11 -0700 (PDT)
Message-ID: <20100603.031911.140764590.davem@davemloft.net>
References: <20100602191547.GA16211@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dkirjanov@hera.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55448
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758680Ab0FCKTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:19:04 -0400
In-Reply-To: <20100602191547.GA16211@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Date: Wed, 2 Jun 2010 19:15:47 +0000

> Convert TX hook return value to netdev_tx_t
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Applied.
