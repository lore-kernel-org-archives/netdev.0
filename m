From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: via-rhine -- VT6105M and checksum offloading
Date: Fri, 25 Feb 2011 19:35:28 +0100
Message-ID: <4D67F670.7010207@computer.org>
References: <20110224185805.GI30393@kvack.org> <20110224.122354.193728354.davem@davemloft.net> <20110225075303.GA8748@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay011.isp.belgacom.be ([195.238.6.178]:19487 "EHLO
	mailrelay011.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756241Ab1BYShe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 13:37:34 -0500
In-Reply-To: <20110225075303.GA8748@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/02/11 08:53, Roger Luethi wrote:
> I have a patch to enable hw checksumming (the ethtool hooks are done, but I
> somehow missed the NETIF_F_GRO bit). Care to give it a whirl?

Can you post that, preferably rebased to net-next? Even if Benjamin 
doesn't get 'round to implementing all of the improvements Dave proposes 
perhaps Dave will be clement enough to apply it as-is if it proves to be 
a net positive?

Thanks, Jan
