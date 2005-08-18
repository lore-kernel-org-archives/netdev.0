From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix dst_entry leak in icmp_push_reply()
Date: Thu, 18 Aug 2005 14:32:24 -0700 (PDT)
Message-ID: <20050818.143224.111875937.davem__25355.2249553197$1124401058$gmane$org@davemloft.net>
References: <4304D763.4090001@rincewind.tv>
	<4304DA99.2080205@trash.net>
	<4304DBFB.5010906@rincewind.tv>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: aaw@rincewind.tv
In-Reply-To: <4304DBFB.5010906@rincewind.tv>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Ollie Wild <aaw@rincewind.tv>
Date: Thu, 18 Aug 2005 12:05:31 -0700

> Patrick McHardy wrote:
> 
> >Checking the return value of ip_append_data seems cleaner to me.
> >Patch attached.
> >  
> >
> Works for me.

Applied, thanks everyone.
