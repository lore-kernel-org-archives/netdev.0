From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules
 Framework
Date: Fri, 28 Jul 2006 01:31:31 +0200
Message-ID: <44C94CD3.4030108@trash.net>
References: <20060726.230230.111423566.davem@davemloft.net>	<20060727223931.GZ14627@postel.suug.ch>	<44C94529.5080605@trash.net> <20060727.161746.120621542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jmorris@namei.org, netdev@vger.kernel.org,
	vnuorval@tcs.hut.fi, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:29064 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751560AbWG0XdK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 19:33:10 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060727.161746.120621542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 28 Jul 2006 00:58:49 +0200
> 
>>This clashes with my routing table patch, guess we have to figure
>>out who should go first :)
> 
> 
> I think since USAGI has some work that depends on this, we
> should get Thomas's stuff in first.

OK.

> It shouldn't be a big deal to rework your >256 tables patch
> against Thomas's should it?

No, that shouldn't be much work.
