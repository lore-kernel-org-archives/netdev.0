From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WiMAX-next for 2.6.30
Date: Mon, 02 Mar 2009 03:12:22 -0800 (PST)
Message-ID: <20090302.031222.147565849.davem@davemloft.net>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
	<200903010156.51110.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752126AbZCBLMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 06:12:41 -0500
In-Reply-To: <200903010156.51110.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Sun, 1 Mar 2009 01:56:50 -0800

> Apologies, I just realized I missed sending the cover letter
> 
> This patch series corresponds to the wimax-next tree as it stands
> today, with feature additions for the i2400m driver:
> 
>  - support extended data-RX protocol and data-RX reordering
>  - ability to query for a list of firmware files if the default
>    doesn't work
>  - control of base station idle mode timeout (with firmware >= 1.4).
> 
> The wimax stack NAP level interface (scan, connect, disconnect, etc) 
> that has been proposed in the mailing list is still not really ready 
> for merging, so it will be kept in a branch of wimax-next.

All applied to net-next-2.6, thanks!
