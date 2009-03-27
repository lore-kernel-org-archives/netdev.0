From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 2/5] cxgb3: sge setup fixes
Date: Fri, 27 Mar 2009 00:53:04 -0700 (PDT)
Message-ID: <20090327.005304.267479164.davem@davemloft.net>
References: <20090327023909.32137.93884.stgit@speedy5>
	<20090327023914.32137.29655.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36365
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755648AbZC0HxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:53:16 -0400
In-Reply-To: <20090327023914.32137.29655.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Thu, 26 Mar 2009 19:39:14 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Enable timestamps, update delayed ack threshold for iSCSI/iWARP traffic
> Remove the len flag in Tx requests. It might corrupt offload trace packets.
> Update SGE context setup to avoid potential H/W misprogrammation.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
