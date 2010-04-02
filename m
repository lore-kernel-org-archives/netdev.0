From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] be2net: Adding PCI SRIOV support
Date: Thu, 01 Apr 2010 19:54:56 -0700 (PDT)
Message-ID: <20100401.195456.234043981.davem@davemloft.net>
References: <20100331125601.GA9725@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44081
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932169Ab0DBCyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 22:54:55 -0400
In-Reply-To: <20100331125601.GA9725@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Wed, 31 Mar 2010 18:26:12 +0530

> - Patch adds support to enable PCI SRIOV in the driver and changes to handle initialization of PCI virtual functions.
> - Function handler to change mac addresses for VF from its corresponding PF.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>

Applied, thanks.
