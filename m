From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Tue, 08 Oct 2002 09:37:21 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021008.093721.11469009.yoshfuji@linux-ipv6.org>
References: <20021008.000559.17528416.yoshfuji@linux-ipv6.org>
	<20021007.115530.00078126.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20021007.115530.00078126.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20021007.115530.00078126.davem@redhat.com> (at Mon, 07 Oct 2002 11:55:30 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

> BTW, we start to run into conflicts now and most of USAGI patches now
> I need to apply some parts by hand.  Here is one example, with this
> patch:
:
> It is not such a big deal now, but it may soon become larger as
> bigger USAGI patches are applied.  We will need to synchronize
> at some point.

Agreed.

So,... What kind of patches do you prefer, now?

 - on top of plain kernel (2.4.19, 2.4.20, 2.4.21-preXX, or whatever)
 - plain kernel + on top of our whole patch?
 - ???

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
