From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: (usagi-core 31424) Re: [PATCH 7/13] [RFC] [IPV6] Move source
 address selection into route lookup.
Date: Thu, 02 Nov 2006 22:13:39 +0900 (JST)
Message-ID: <20061102.221339.102356265.yoshfuji@linux-ipv6.org>
References: <20061018.230850.91573842.yoshfuji@linux-ipv6.org>
	<4536E279.1090003@jp.ibm.com>
	<4549E8B3.4070601@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch@jp.ibm.com, usagi-core@linux-ipv6.org, davem@davemloft.net,
	tgraf@suug.ch, kim.nordlund@nokia.com, netdev@vger.kernel.org,
	jean-mickael.guerin@6wind.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:9995 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1752771AbWKBNKv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 08:10:51 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <4549E8B3.4070601@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4549E8B3.4070601@tcs.hut.fi> (at Thu, 02 Nov 2006 14:46:43 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> > http://testlab.linux-ipv6.org/tahi-autorun.2/net-2.6_20061018/
> 
> The host testlab.linux-ipv6.org doesn't seem to be visible to the
> outside world so could you post the results somewhere where I could take
> a closer look at the results?

It is visible world-wide, assuming you have IPv6 connection.

> Could you actually also send me the configuration files for the TAHI
> test, so I could try to set up an identical test environment?

Nothing special.

--yoshfuji
