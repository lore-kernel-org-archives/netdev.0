From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [OOPS] less /proc/net/igmp
Date: Wed, 27 Aug 2003 08:39:26 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827.083926.50662159.yoshfuji@linux-ipv6.org>
References: <20030826.173226.114994096.yoshfuji@linux-ipv6.org>
	<20030827.015448.70287953.yoshfuji@linux-ipv6.org>
	<1061929108.3946.1.camel@spider.hotmonkeyporn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <1061929108.3946.1.camel@spider.hotmonkeyporn.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1061929108.3946.1.camel@spider.hotmonkeyporn.com> (at 26 Aug 2003 15:18:28 -0500), Owen Ford <oford@arghblech.com> says:

> > > Okay, everyone. I'll try to fix this.
> > 
> > Please try this patch.
> 
> That seems to have done the job nicely.  Thanks.

Thanks.  David, please apply.

D: Fixing several refcnt mistakes in seq_file handlers for 
D: /proc/net/{igmp,igmp6,msfilter,msfilter6}.

Thanks in advance.

--yoshfuji
