From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Tue, 15 Apr 2003 01:40:47 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030415.014047.39346510.yoshfuji@linux-ipv6.org>
References: <20030414080347.0af818f7.rddunlap@osdl.org>
	<20030415.002915.71906095.yoshfuji@linux-ipv6.org>
	<20030414.090610.117741299.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, linux-net@vger.kernel.org, netdev@oss.sgi.com,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030414.090610.117741299.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030414.090610.117741299.davem@redhat.com> (at Mon, 14 Apr 2003 09:06:10 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

> So we'd then have /proc/net/dev_snmp6/{lo,eth0,eth1} etc.
> 
> Ok?

Okay.  I'd like to see ifIndex in that file, too.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
