From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC][NET-NEXT PATCH 2/2] net: Add GSO to vlan_features initialization
Date: Tue, 28 Jun 2011 11:47:51 +0800
Message-ID: <4E094EE7.1000203@cn.fujitsu.com>
References: <4E0406BE.50900@cn.fujitsu.com> <1308934302.3034.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	"therbert@google.com" <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65531 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756373Ab1F1Dqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 23:46:52 -0400
In-Reply-To: <1308934302.3034.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben:

Ben Hutchings wrote, at 06/25/2011 12:51 AM:
> Have you verified that GSO works correctly for VLAN devices if the
> underlying device does not support VLAN tag insertion?

OK. I will do some test in future days.
Then report test results.

-- 
Best Regards
-----
Shan Wei
