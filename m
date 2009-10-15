From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] be2net: fix support for PCI hot plug
Date: Wed, 14 Oct 2009 23:30:17 -0700 (PDT)
Message-ID: <20091014.233017.263084740.davem@davemloft.net>
References: <20091015062117.GA31504@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754851AbZJOGaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 02:30:20 -0400
In-Reply-To: <20091015062117.GA31504@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Thu, 15 Oct 2009 11:51:17 +0530

> Before issuing any cmds to the FW, the driver must first wait
> till the fW becomes ready. This is needed for PCI hot plug when
> the driver can be probed while the card fw is being initialized.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
