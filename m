From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: (usagi-core 12294) Re: [PATCH] IPv6 IPsec support
Date: Thu, 06 Mar 2003 00:48:20 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030306.004820.41101302.yoshfuji@linux-ipv6.org>
References: <20030305233025.784feb00.kazunori@miyazawa.org>
	<20030305.072149.121185037.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030305.072149.121185037.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030305.072149.121185037.davem@redhat.com> (at Wed, 05 Mar 2003 07:21:49 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

> I will apply your patch after basic build testing.

Thank you.

> The next large task will be to abstract out more common
> pieces of code.  There is still quite a bit of code duplication
> between v4 and v6 xfrm methods,

Yes, we will do that.  That patch is first step for reducing 
duplicate codes between IPv4 and IPv6.

--yoshfuji
