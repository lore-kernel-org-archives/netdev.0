From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@wide.ad.jp>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.45
Date: Fri, 01 Nov 2002 11:36:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021101.113612.10745857.yoshfuji@wide.ad.jp>
References: <200211010219.gA12JMn11699@eng2.beaverton.ibm.com>
	<20021031.181708.102783497.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, kuznet@ms2.inr.ac.ru, ajtuomin@tml.hut.fi,
   lpetande@tml.hut.fi, jagana@us.ibm.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20021031.181708.102783497.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20021031.181708.102783497.davem@redhat.com> (at Thu, 31 Oct 2002 18:17:08 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

> 
> Why isn't the home agent code being done in userspace?  That is
> where it belongs.  It's huge.

I think core part of HA belongs to kernel (forwarding etc.)
Registration process should live in user space.

--yoshfuji
