From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: OOPS in ip6_output2
Date: Fri, 18 Jul 2003 11:55:28 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030718.115528.21456710.yoshfuji@linux-ipv6.org>
References: <20030717151354.GA10640@h55p111.delphi.afb.lu.se>
	<20030718.114012.60686118.yoshfuji@linux-ipv6.org>
	<20030718094615.GD5964@h55p111.delphi.afb.lu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: andersg@0x63.nu
In-Reply-To: <20030718094615.GD5964@h55p111.delphi.afb.lu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030718094615.GD5964@h55p111.delphi.afb.lu.se> (at Fri, 18 Jul 2003 11:46:15 +0200), Anders Gustafsson <andersg@0x63.nu> says:

> Latest bk as of wednesday I think.
> 
> It did just happen once in that kernel, so I don't really know if it's
> solved in latest bk which I run now.

Well, I fixed a refcnt bug on Wednesday.
Please tell us if you saw similar bug again.
Thanks.
--yoshfuji
