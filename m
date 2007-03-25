From: David Miller <davem@davemloft.net>
Subject: Re: [TG3 1/3]: Eliminate the unused TG3_FLAG_SPLIT_MODE flag.
Date: Sat, 24 Mar 2007 20:54:47 -0700 (PDT)
Message-ID: <20070324.205447.07642914.davem@davemloft.net>
References: <1174601067.9753.42.camel@dell>
	<20070322232048.GC3333@sykes.suse.de>
	<1174695177.4834.8.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bwalle@suse.de, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55560
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932687AbXCYDzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 23:55:06 -0400
In-Reply-To: <1174695177.4834.8.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 23 Mar 2007 16:12:57 -0800

> [TG3]: Eliminate the unused TG3_FLAG_SPLIT_MODE flag.
> 
> This flag to support multiple PCIX split completions was never used
> because of hardware bugs.  This will make room for a new flag.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
