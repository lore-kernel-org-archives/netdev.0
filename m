From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Fri, 16 Jan 2004 04:53:41 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.045341.11259916.yoshfuji@linux-ipv6.org>
References: <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com>
	<20040115113840.4b7eb5d8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xma@us.ibm.com, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040115113840.4b7eb5d8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040115113840.4b7eb5d8.davem@redhat.com> (at Thu, 15 Jan 2004 11:38:40 -0800), "David S. Miller" <davem@redhat.com> says:

> We can create new files to present information in new ways and formats,
> but I totally prefer using netlink based information gathering over making
> new procfs files.

Although this discussion is about rtnetlink message,
problem will be solved if we provide jiffies for neigbours 
IMHO.

--yoshfuji @ let me sleep...
