From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] icom: Add new sub-device-id to support new adapter
Date: Tue, 15 May 2007 09:50:55 -0700
Message-ID: <20070515095055.f1d73a19.akpm@linux-foundation.org>
References: <1178750192.18147.111.camel@wendyx.austin.ibm.com>
	<1179246555.18147.128.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wendy xiong <wendyx@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41738 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753395AbXEORDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 13:03:42 -0400
In-Reply-To: <1179246555.18147.128.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 May 2007 11:29:15 -0500 wendy xiong <wendyx@us.ibm.com> wrote:

> I have tested this with new adapter on our systems. I didn't get
> comments since I sent out last Wednesday.
> 
> Could you help me with this patch?

You sent it to the wrong mailing list: netdev doesn't handle serial drivers.
I don't normally troll netdev for missed patches.

Please send miscellaneous patches to linux-kernel.

Your email client is replacing tabs with spaces - I fixed that up.

The undersized irq number bug was already fixed.

Thanks for the patch.
