From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] skb fragment API: convert network drivers (part V)
Date: Mon, 10 Oct 2011 14:20:40 -0400 (EDT)
Message-ID: <20111010.142040.2267571270586671416.davem@davemloft.net>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-mm@kvack.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643Ab1JJSUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 14:20:47 -0400
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 10 Oct 2011 12:11:16 +0100

> I think "struct subpage" is a generally useful tuple I added to a
> central location (mm_types.h) rather than somewhere networking or driver
> specific but I can trivially move if preferred.

I'm fine with the patch series, but this generic datastructure
addition needs some feedback first.
