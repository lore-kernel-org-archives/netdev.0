From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] flow_dissector: clean up IPIP case
Date: Tue, 30 Jul 2013 19:17:02 -0700 (PDT)
Message-ID: <20130730.191702.2134256202048192295.davem@davemloft.net>
References: <alpine.DEB.2.02.1307291103330.21411@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab3GaCRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 22:17:03 -0400
In-Reply-To: <alpine.DEB.2.02.1307291103330.21411@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 29 Jul 2013 11:07:36 -0700 (PDT)

> Explicitly set proto to ETH_P_IP and jump directly to ip processing.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied.
