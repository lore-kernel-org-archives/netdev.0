From: David Miller <davem@davemloft.net>
Subject: Re: 9p: restrict RDMA usage
Date: Wed, 12 Nov 2008 23:35:12 -0800 (PST)
Message-ID: <20081112.233512.181207552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39436
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751235AbYKMHfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 02:35:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've applied this to net-2.6 thanks Randy.

I didn't get it earlier because I thought perhaps the
Infiniband folks might want to have picked this one up.
