From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/5] be2net: Use cancel_delayed_work_sync
 instead of cancel_delayed_work()
Date: Thu, 11 Jun 2009 02:49:59 -0700 (PDT)
Message-ID: <20090611.024959.69713825.davem@davemloft.net>
References: <20090610121835.GA16411@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35524
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757255AbZFKJt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:49:56 -0400
In-Reply-To: <20090610121835.GA16411@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 10 Jun 2009 17:48:35 +0530

> Use cancel_delayed_work_sycn instead of cancel_delayed_work() to reliably kill be_worker() as it rearms itself.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
