From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Subject: Re: [PATCH] LVS: Send ICMP unreachable responses to end-users when
 real-servers are removed
Date: Tue, 27 Mar 2007 12:53:39 +0200
Message-ID: <4608F7B3.7030803@tis.icnet.pl>
References: <20070211030441.GB3383@verge.net.au> <20070326.180408.18304339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, netdev@vger.kernel.org, ja@ssi.bg,
	wensong@linux-vs.org, jmack@wm7d.net, ratz@drugphish.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d1.icnet.pl ([212.160.220.21]:50866 "EHLO d1.icnet.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798AbXC0KyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 06:54:01 -0400
In-Reply-To: <20070326.180408.18304339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>> this is a small patch by  Janusz Krzysztofik to ip_route_output_slow()
>> that allows VIP-less LVS linux director to generate packets originating
>> >From VIP if sysctl_ip_nonlocal_bind is set.
> 
> Applied to net-2.6.22, thanks Simon.

Thank you,

Janusz

