From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: add missing sentinel for addrconf procfs
Date: Wed, 21 Jan 2004 11:30:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040121.113029.39883350.yoshfuji@linux-ipv6.org>
References: <20040120.094223.76534381.yoshfuji@linux-ipv6.org>
	<20040120104820.77ff135f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20040120104820.77ff135f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040120104820.77ff135f.shemminger@osdl.org> (at Tue, 20 Jan 2004 10:48:20 -0800), Stephen Hemminger <shemminger@osdl.org> says:

> > Sorry, I forgot to increase the number of members in the array and 
> > that the sentinel was removed.
> > So, add missing sentinel explicitly.
> 
> How about adding all them explicitly to prevent future errors?

agreed.

--yoshfuji
