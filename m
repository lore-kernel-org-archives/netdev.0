From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 9920] New: kernel panic when using ebtables
 redirect target
Date: Mon, 18 Feb 2008 20:53:17 -0800 (PST)
Message-ID: <20080218.205317.62981417.davem@davemloft.net>
References: <bug-9920-10286@http.bugzilla.kernel.org/>
	<20080208175942.a8b495ac.akpm@kernel.org>
	<20080219025324.GA27084@ehus.geninetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	mingching.tiew@redtone.com, kaber@trash.net
To: joonwpark81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43085
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbYBSEwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 23:52:40 -0500
In-Reply-To: <20080219025324.GA27084@ehus.geninetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joonwoo Park <joonwpark81@gmail.com>
Date: Tue, 19 Feb 2008 11:53:24 +0900

> [PATCH] netfilter: fix incorrect use of skb_make_writable
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=9920
> The function skb_make_writable returns true or false.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

I'll let Patrick pull this in, thanks!
