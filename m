From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH v2] net: zero kobject in rx_queue_release
Date: Thu, 18 Nov 2010 09:42:16 -0800 (PST)
Message-ID: <20101118.094216.48502770.davem@davemloft.net>
References: <20101117054253.8714.24548.stgit@jf-dev1-dcblab>
	<1289973119.2732.104.camel@edumazet-laptop>
	<4CE36F9E.4070508@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34873
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932783Ab0KRRlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 12:41:52 -0500
In-Reply-To: <4CE36F9E.4070508@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 16 Nov 2010 22:01:02 -0800

> net-next has Tom's changes for queue allocation and freeing. So the
> net-2.6 patch and net-next-2.6 patches are slightly different. I
> wanted to get the RCU_INIT_POINTER update in both and thought it
> would be easiest for Dave if they applied cleanly on both
> tree's. Let me know if there is a better way to indicate that here I
> just used the prefix net and net-next.

Right, applied, thanks everyone.
