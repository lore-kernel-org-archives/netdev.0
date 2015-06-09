From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Mon, 08 Jun 2015 19:03:18 -0600
Message-ID: <55763B56.3000503@gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>	 <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com> <1433793517.4616.4.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	hadi@mojatatu.com, davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36795 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbbFIBDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 21:03:21 -0400
Received: by igbpi8 with SMTP id pi8so1656306igb.1
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 18:03:20 -0700 (PDT)
In-Reply-To: <1433793517.4616.4.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/15 1:58 PM, Hannes Frederic Sowa wrote:
> For rx layer I want to also propose my try:
>
> [PATCH net-next RFC] net: ipv4: arp: strong end system model semantics by per-interface local table override
>

I applied only the first 2 patches from Shrijeet and then tried to apply 
your patch; it doesn't apply. Way too many failures. What branch should 
it apply too?
