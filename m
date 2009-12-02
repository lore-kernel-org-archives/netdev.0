From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 4/6] be2net: fix to allow port beacon when
 device is closed
Date: Wed, 02 Dec 2009 01:11:22 -0800 (PST)
Message-ID: <20091202.011122.54221622.davem@davemloft.net>
References: <20091130035646.GA15530@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57211
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755122AbZLBJLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 04:11:16 -0500
In-Reply-To: <20091130035646.GA15530@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Mon, 30 Nov 2009 09:26:56 +0530

> port identification/beaconing is failing if device open has not been done.
> Fixing it.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
