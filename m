From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: PROBLEM: nd_tbl not a public symbol in net/ipv6/ndisc.c
Date: Thu, 24 Feb 2005 18:34:53 +0900 (JST)
Message-ID: <20050224.183453.06326363.yoshfuji@linux-ipv6.org>
References: <20050131.190157.42878368.yoshfuji@linux-ipv6.org>
	<Pine.OSF.4.58.0501311111380.2054@igor.urz.unibas.ch>
	<Pine.OSF.4.58.0502240942570.11226@igor.urz.unibas.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
To: Christian.Tschudin@unibas.ch
In-Reply-To: <Pine.OSF.4.58.0502240942570.11226@igor.urz.unibas.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.OSF.4.58.0502240942570.11226@igor.urz.unibas.ch> (at Thu, 24 Feb 2005 09:47:39 +0100 (MET)), Christian Tschudin <Christian.Tschudin@unibas.ch> says:

> three weeks ago we had a message exchang on nd_tbl not
> being a public symbol; I had sent you some code for showing
> the usage.
> 
> What do you think now?

I believe you can manage (map/unmap) neighbour entries via netlink.

--yoshfuji
