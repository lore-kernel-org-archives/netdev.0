From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 net-next-2.6] [TIPC]: Add support for customized
 subscription overlap handling
Date: Mon, 19 May 2008 13:30:22 -0700 (PDT)
Message-ID: <20080519.133022.217066017.davem@davemloft.net>
References: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
	<1210702665-5012-2-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757659AbYESUa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:30:27 -0400
In-Reply-To: <1210702665-5012-2-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 13 May 2008 14:17:41 -0400

> This patch enables TIPC's topology server code to do customized
> overlap detection handling on a per-subscription basis.  (This
> capability is needed to support the upcoming introduction of
> multi-cluster TIPC networks.)
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
