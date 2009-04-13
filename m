From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] be2net: changes for checksum and segmentation
 offload
Date: Mon, 13 Apr 2009 15:40:16 -0700 (PDT)
Message-ID: <20090413.154016.104828718.davem@davemloft.net>
References: <20090413080434.GC6824@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751029AbZDMWkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 18:40:25 -0400
In-Reply-To: <20090413080434.GC6824@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Mon, 13 Apr 2009 13:34:35 +0530

> Hi, this patch does the following:
> 
> - Enables Rx checksum feature by default.
> - Disables support for ipv6 tso.
> - Changes in Rx path to handle Rx completions with various checksum options.

This is a feature patch, I'm not applying it to net-2.6,
but rather I'll apply it to net-next-2.6

