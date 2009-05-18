From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] be2net: add two new pci device ids to pci device
 table
Date: Mon, 18 May 2009 15:38:13 -0700 (PDT)
Message-ID: <20090518.153813.187765090.davem@davemloft.net>
References: <20090518100807.GA22855@serverengines.com>
	<20090518.114302.134669848.davem@davemloft.net>
	<20090518223344.GA25192@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49279
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754367AbZERWiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:38:15 -0400
In-Reply-To: <20090518223344.GA25192@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Tue, 19 May 2009 04:03:46 +0530

> David, thanks for the reply. There is a slight sense of urgency to see this 
> patch in the upstream kernel. Hence I am sending this patch which I have
> spun again - against the net-2.6 tree. Please accept. I hope it applies this
> time.

I'll apply this to net-2.6 sure, but I wasn't saying this
patch didn't apply correctly.

I was talking about the patch that moved the NAPI stuff out the TX
work stuff in this driver.  That's the patch that wouldn't apply
correctly.

This one:

	http://patchwork.ozlabs.org/patch/27312/
