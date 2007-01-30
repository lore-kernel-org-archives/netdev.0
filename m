From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
 packets
Date: Tue, 30 Jan 2007 16:24:41 +0900 (JST)
Message-ID: <20070130.162441.39376131.yoshfuji@linux-ipv6.org>
References: <1172042666.4512.8.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org,
	yoshifuji@linux-ipv6.org, yoshfuji@linux-ipv6.org
To: weid@np.css.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47517 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965256AbXA3HX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 02:23:26 -0500
In-Reply-To: <1172042666.4512.8.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <1172042666.4512.8.camel@LINE> (at Wed, 21 Feb 2007 02:24:26 -0500), weidong <weid@np.css.fujitsu.com> says:

>          eth0: fe80::20c:29ff:fe24:fa0a
>             |                     eth1: fe80::20c:29ff:fe24:fa14 
>             |                      |
> ------------------------------------------------
>             |                      |
>             |                      |
>             | LAN1                 |LAN2
>             |                      |
>           -----
>             ^
>             |  
>      Send Echo Request(src addr = fe80::200:ff:fe00:100)

Sorry, I could not understand this figure....
Would you elaborate this?

--yoshfuji
