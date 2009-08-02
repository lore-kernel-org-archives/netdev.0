From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/5] be2net: remove pci_func field from
 be_adapter struct
Date: Sat, 01 Aug 2009 23:07:50 -0700 (PDT)
Message-ID: <20090801.230750.96478424.davem@davemloft.net>
References: <20090728085223.GA4977@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751479AbZHBGHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 02:07:42 -0400
In-Reply-To: <20090728085223.GA4977@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 28 Jul 2009 14:22:23 +0530

> pci function is available as PCI_FUNC(pdev->devfn); no need for a
> separate field.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
