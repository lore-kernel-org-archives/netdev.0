From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6.19] [IPV6]: Fix address/interface handling in UDP
 and DCCP, according to the scoping architecture.
Date: Tue, 21 Nov 2006 10:29:11 +0900 (JST)
Message-ID: <20061121.102911.94853029.yoshfuji@linux-ipv6.org>
References: <20061121.014306.76909112.yoshfuji@linux-ipv6.org>
	<20061120.093222.79066541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:49280 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1030244AbWKUB3O
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 20:29:14 -0500
To: davem@davemloft.net
In-Reply-To: <20061120.093222.79066541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061120.093222.79066541.davem@davemloft.net> (at Mon, 20 Nov 2006 09:32:22 -0800 (PST)), David Miller <davem@davemloft.net> says:

> I tried yesterday to pull your other fixes from branch
> "2.6.19-rc6-20061117-to-davem-20061117" at
> git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev/
> but it doesn't work:
> 
> error: no such remote ref refs/heads/2.6.19-rc6-20061117-to-davem-20061117
> Fetch failure: git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev/
> 
> Can you fix this up so I can pull in those bug fixes, or tell
> me what I am doing wrong? :-)

Oops, sorry.  Please try fetching from:
	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>,
replacing trailing "/" with ".git".

Regards,

P.S. Git seems to handle both cases.  StGit does not, maybe?

--yoshfuji
