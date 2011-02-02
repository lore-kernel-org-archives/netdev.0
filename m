From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/6] [resend] s390: network patches for net-next
Date: Wed, 02 Feb 2011 15:01:08 -0800 (PST)
Message-ID: <20110202.150108.48516123.davem@davemloft.net>
References: <20110202160430.554090958@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755268Ab1BBXAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:00:33 -0500
In-Reply-To: <20110202160430.554090958@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Wed, 02 Feb 2011 17:04:30 +0100

> Hi Dave,
> 
> I have removed the NET_SKB_PAD patch from the patch set.
> We will define it in an arch specific header. The new
> version of the patch will come via the s390 tree. Thx!

All applied, thanks Frank.
