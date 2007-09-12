From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] cxgb3 - napi update
Date: Wed, 12 Sep 2007 07:55:41 -0700 (PDT)
Message-ID: <20070912.075541.26980120.davem@davemloft.net>
References: <20070909070917.27016.76853.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:57294
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966391AbXILOzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 10:55:53 -0400
In-Reply-To: <20070909070917.27016.76853.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Sun, 09 Sep 2007 00:09:17 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Embed napi_struct directly into sge_qset.
> Use napi_schedule/napi_complete.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Patch applied, thanks a lot!
