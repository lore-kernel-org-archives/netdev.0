From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Fri, 16 Jan 2004 04:47:34 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.044734.108733295.yoshfuji@linux-ipv6.org>
References: <OFC6D64AE0.CEE7DA5F-ON87256E1C.0068A56A@us.ibm.com>
	<20040116.041950.35757995.yoshfuji@linux-ipv6.org>
	<20040115113700.166ddfb0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xma@us.ibm.com, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040115113700.166ddfb0.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040115113700.166ddfb0.davem@redhat.com> (at Thu, 15 Jan 2004 11:37:00 -0800), "David S. Miller" <davem@redhat.com> says:

> And also, the current situation is OK as long as this value we present now
> can be converted into the desired value.  Is this the case?

I think so for the routing table AFAIK.
For neighbours, "jiffies" is required to be exported.

--yoshfuji
