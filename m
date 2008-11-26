From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4 2.6.29] cxgb3 - avoid potential memory leak.
Date: Wed, 26 Nov 2008 15:36:06 -0800 (PST)
Message-ID: <20081126.153606.10175544.davem@davemloft.net>
References: <20081126203820.4819.17969.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44438
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752548AbYKZXgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:36:07 -0500
In-Reply-To: <20081126203820.4819.17969.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 26 Nov 2008 12:38:20 -0800

> From: Divy Le Ray <divy@chelsio.com>
> 
> Add consistency in alloc_ring() parameter checking
> to avoid potential memory leaks.
> alloc_ring() callers are correct fo far.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
