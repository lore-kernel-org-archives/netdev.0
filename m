From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/5] be2net: Fix rx stats updation in non-lro
 path
Date: Thu, 11 Jun 2009 02:50:10 -0700 (PDT)
Message-ID: <20090611.025010.48218493.davem@davemloft.net>
References: <20090610122156.GA16719@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761950AbZFKJuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:50:08 -0400
In-Reply-To: <20090610122156.GA16719@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 10 Jun 2009 17:51:56 +0530

> rx stats are not getting updated when an rx_compl with only one frag is rcvd in non-lro path.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
