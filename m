From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] via-velocity: Enable scatter/gather IO by
 default
Date: Wed, 17 Feb 2010 16:01:29 -0800 (PST)
Message-ID: <20100217.160129.75768372.davem@davemloft.net>
References: <20100211163955.1b1dbe2c@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krkumar2@in.ibm.com
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751344Ab0BRABQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 19:01:16 -0500
In-Reply-To: <20100211163955.1b1dbe2c@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Thu, 11 Feb 2010 16:39:55 +0100

> Reduces CPU utilization significantly with sendfile for example.
> 
> Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>

Applied.
