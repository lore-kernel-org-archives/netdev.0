From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.43
Date: Thu, 31 Oct 2002 18:08:53 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021031.180853.380251036.yoshfuji@linux-ipv6.org>
References: <20021031.174442.846937513.takamiya@po.ntts.co.jp>
	<Pine.LNX.4.44.0210311053570.19356-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takamiya@po.ntts.co.jp, ajtuomin@morphine.tml.hut.fi, davem@redhat.com,
   kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
   torvalds@transmeta.com, jagana@us.ibm.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0210311053570.19356-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0210311053570.19356-100000@netcore.fi> (at Thu, 31 Oct 2002 10:55:56 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:

> > (7) Source Address Selection of MN
> > 	When host acts as MN, your implementation always select HoA as the
> > 	source address. The source address should be a CoA. 
> 
> No, draft-ietf-ipv6-default-addr-select-09.txt Rule 4 says home addresses 
> should be preferred, except via a possible API interaction.

Yes, we know.

What we meant was there are some cases that we need to use actual 
address on the device, not HoA.

---yoshfuji
