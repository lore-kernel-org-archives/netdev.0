From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.19] [IPV6]: Fix address/interface handling in UDP
 and DCCP, according to the scoping architecture.
Date: Mon, 20 Nov 2006 09:32:22 -0800 (PST)
Message-ID: <20061120.093222.79066541.davem@davemloft.net>
References: <20061121.014306.76909112.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:18305
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966258AbWKTRcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 12:32:20 -0500
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20061121.014306.76909112.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 21 Nov 2006 01:43:06 +0900 (JST)

> [IPV6]: Fix address/interface handling in UDP and DCCP, according to the scoping architecture.
> 
> TCP and RAW do not have this issue.  Closes Bug #7432.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Thank you, I will look at this and apply it.

I tried yesterday to pull your other fixes from branch
"2.6.19-rc6-20061117-to-davem-20061117" at
git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev/
but it doesn't work:

error: no such remote ref refs/heads/2.6.19-rc6-20061117-to-davem-20061117
Fetch failure: git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev/

Can you fix this up so I can pull in those bug fixes, or tell
me what I am doing wrong? :-)

Thanks!
