From: Madoka Komatsubara <m-komatsubara@ab.jp.nec.com>
Subject: RE: [E1000-devel] fail to add 64 VLANs or more when SR-IOV is
 enabled
Date: Thu, 3 Apr 2014 02:03:43 +0000
Message-ID: <9DE5760509B7974286F38D93BF31DD62C7E200@BPXM13GP.gisp.nec.co.jp>
References: <9DE5760509B7974286F38D93BF31DD62C7DF93@BPXM13GP.gisp.nec.co.jp>
	<9B4A1B1917080E46B64F07F2989DADD652978166@ORSMSX102.amr.corp.intel.com>
	<9DE5760509B7974286F38D93BF31DD62C7E125@BPXM13GP.gisp.nec.co.jp>
 <20140402.213941.1530194697006154708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Hiroshi Baba <h-baba@ax.jp.nec.com>
To: David Miller <davem@davemloft.net>,
	"todd.fujinaka@intel.com" <todd.fujinaka@intel.com>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140402.213941.1530194697006154708.davem@davemloft.net>
Content-Language: ja-JP
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, April 03, 2014 10:40 AM
> To: Komatsubara Madoka(小松原 円)
> Cc: todd.fujinaka@intel.com; donald.c.skidmore@intel.com;
> linux-kernel@vger.kernel.org; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org; Shimamoto Hiroshi(島本 裕志); Baba Hiroshi(馬場 裕
> 司)
> Subject: Re: [E1000-devel] fail to add 64 VLANs or more when SR-IOV is enabled
> 
> From: Madoka Komatsubara <m-komatsubara@ab.jp.nec.com>
> Date: Thu, 3 Apr 2014 01:12:13 +0000
> 
> > Thank you for the quick response.
> > How can I increase the limit？
> 
> It's a hardware limit, you cannot increase it.


Thank you for your information.
Does it mean disabling filter is the only way to use over 64 VLANs and is it possible?

Regards,
Madoka
