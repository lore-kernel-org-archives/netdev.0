From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] Prefix List and O/M flags against 2.4.21
Date: Fri, 18 Jul 2003 00:22:09 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030718.002209.104303756.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0307171336430.1353-100000@DYN318430.beaverton.ibm.com>
	<Pine.LNX.4.44.0307171413100.1353-100000@DYN318430.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com
In-Reply-To: <Pine.LNX.4.44.0307171413100.1353-100000@DYN318430.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0307171413100.1353-100000@DYN318430.beaverton.ibm.com> (at Thu, 17 Jul 2003 15:06:02 -0700 (PDT)), Krishna Kumar <krkumar@us.ibm.com> says:

> The same patch against 2.4.21

Hmm, you seems still misunderstanding some of our points. :-p
Alexey says we may want to use ifi_family for per-interface L3 information
including M/O bits. 
At least, new RTM_xxx should not be restricted to get such flags.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
