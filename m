From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6 v2] au1000-eth: typedefs removal
Date: Tue, 17 Aug 2010 17:51:36 -0700 (PDT)
Message-ID: <20100817.175136.71105773.davem@davemloft.net>
References: <201008121009.49706.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752114Ab0HRAvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 20:51:17 -0400
In-Reply-To: <201008121009.49706.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set doesn't apply cleanly to net-next-2.6, please respin
and also please address the feedback to patch #3 given by Joe
Perches.

And also, please don't format comments in such an ugly way, use:

/* This is
 * a comment.
 */

Instead of:

/* This is
 * an ugly comment.  */

Thanks.
