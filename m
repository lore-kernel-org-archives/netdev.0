From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Fri, 16 Jan 2004 04:36:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.043650.125087555.yoshfuji@linux-ipv6.org>
References: <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com
In-Reply-To: <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com> (at Thu, 15 Jan 2004 11:30:25 -0800), Shirley Ma <xma@us.ibm.com> says:

> I don't see any application uses these values for now, so I change them.
> It's good for kernel to provide the real MIBs information. If later on,
> some applications start to use these values, they can get the correct
> numbers without converting. Unless you can give me an broken example. :-)

ip -6 route ?

--yoshfuji
