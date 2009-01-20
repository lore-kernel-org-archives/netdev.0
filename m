From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2: annotate bp->phy_lock functions
Date: Tue, 20 Jan 2009 15:27:42 +0200
Message-ID: <1232458062.29087.5.camel@lb-tlvb-eliezer>
References: <1232395910.13386.4.camel@brick>
 <1232396961.13386.7.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2576 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761607AbZATN2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 08:28:47 -0500
In-Reply-To: <1232396961.13386.7.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-19 at 12:29 -0800, Harvey Harrison wrote:
[...]
> Whoops, bnx2 != bnx2x....that driver needs serious help in the endianess
> department, but it doesn't actually lok to hard to sort out as it seems
> most of the warnings come about as the hardware structs are just not
> annotated, but the correct accessors seem to be in place in the code.
> 
> In addition, there are piles of macros in the driver that really shouldn't
> be.  I'll have a look this afternoon at some of the low-hanging fruit.
> 
> Harvey

Thanks Harvey, I appreciate the help

Eilon


