From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/5] be2net: Fix cleanup path in be_probe()
Date: Mon, 23 Nov 2009 10:45:57 -0800 (PST)
Message-ID: <20091123.104557.203980054.davem@davemloft.net>
References: <20091123080226.GA7812@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38694
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754015AbZKWSpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:45:39 -0500
In-Reply-To: <20091123080226.GA7812@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 23 Nov 2009 13:32:26 +0530

> Disabling msix was missing when probe fails after enabling msix.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
