From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: ipv6: no link-local address in 2.6.9
Date: Fri, 22 Oct 2004 01:46:49 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022.014649.13041500.yoshfuji@linux-ipv6.org>
References: <Pine.GSO.4.44.0410211110280.8460-100000@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mroos@linux.ee
In-Reply-To: <Pine.GSO.4.44.0410211110280.8460-100000@math.ut.ee>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.44.0410211110280.8460-100000@math.ut.ee> (at Thu, 21 Oct 2004 11:12:33 +0300 (EEST)), Meelis Roos <mroos@linux.ee> says:

> since upgrading to 2.6.9 (actually yesterdays and todyas BK snapshots),
> my e100 NIC does not get a link-local ipv6 address. ipv6 module is
> loaded and lo has a ::1 address. Currently I have no ipv6 router in this
> network but it still should get a link-local address? Or not anymore?

Yes, it still should.

--yoshfuji
