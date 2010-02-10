From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] net: simplify seq_file code, revised
Date: Wed, 10 Feb 2010 11:31:15 -0800 (PST)
Message-ID: <20100210.113115.28754681.davem@davemloft.net>
References: <4B712849.9040400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: lizf@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751007Ab0BJTbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 14:31:04 -0500
In-Reply-To: <4B712849.9040400@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Zefan <lizf@cn.fujitsu.com>
Date: Tue, 09 Feb 2010 17:18:01 +0800

> This patchset introduces seq_hlist_foo() helpers, and convert
> net/* to seq_hlist_foo() and seq_list_foo().
> 
> Changelog:
> 
> - Add kerneldoc in patch 1/13
> - Fix compile warning in patch 11/13
> - Fix a bug in patch 12/13

All applied to net-next-2.6, thanks!
