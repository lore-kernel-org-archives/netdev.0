From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: use eq-id to calculate cev-isr reg offset
Date: Tue, 02 Feb 2010 07:48:48 -0800 (PST)
Message-ID: <20100202.074848.225652873.davem@davemloft.net>
References: <20100129070836.GA21744@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751445Ab0BBPsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 10:48:35 -0500
In-Reply-To: <20100129070836.GA21744@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Fri, 29 Jan 2010 12:38:36 +0530

> cev-isr reg offset for each function is better calculated using (any) eq-id
> alloted to that function instead of using pci-func number(which
> does not work in some configurations...)
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied to net-2.6, thanks.
