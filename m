From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Thu, 12 Feb 2004 15:39:11 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040212.153911.64115196.yoshfuji@linux-ipv6.org>
References: <20040212.110328.103131455.yoshfuji@linux-ipv6.org>
	<OF3D503D9D.B62072AD-ON88256E38.001BCCBD-88256E38.0023E0FA@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hibi665@oki.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com, davem@redhat.com
In-Reply-To: <OF3D503D9D.B62072AD-ON88256E38.001BCCBD-88256E38.0023E0FA@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF3D503D9D.B62072AD-ON88256E38.001BCCBD-88256E38.0023E0FA@us.ibm.com> (at Wed, 11 Feb 2004 23:34:37 -0700), David Stevens <dlstevens@us.ibm.com> says:

>       What I intended is for ipv6_is_mld() to check this (not
> assume that "skb" is ICMPv6 only). Fixed patch below [blush].
>       Thanks for the reviews,
:

I'll eat this patch.  Comments, if any?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
