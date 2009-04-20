From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 3/4] cxgb3: Fix potential msi-x vector leak
Date: Mon, 20 Apr 2009 02:08:25 -0700 (PDT)
Message-ID: <20090420.020825.244829541.davem@davemloft.net>
References: <20090417222122.8537.43636.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59074
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754860AbZDTJIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:08:37 -0400
In-Reply-To: <20090417222122.8537.43636.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Fri, 17 Apr 2009 15:21:22 -0700

> Release vectors when a MSI-X allocation fails.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
