From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Tue, 09 Jun 2015 08:21:06 -0600
Message-ID: <5576F652.4090903@gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com> <5576AAD2.8010405@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: nicolas.dichtel@6wind.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	hannes@stressinduktion.org, ebiederm@xmission.com,
	hadi@mojatatu.com, davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:32862 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbbFIOVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 10:21:09 -0400
Received: by igbpi8 with SMTP id pi8so14242294igb.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 07:21:08 -0700 (PDT)
In-Reply-To: <5576AAD2.8010405@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas:

On 6/9/15 2:58 AM, Nicolas Dichtel wrote:
> I'm not really in favor of the name 'vrf'. This term is very
> controversial and
> having a consensus of what is/contains a 'vrf' is quite impossible.
> There was already a lot of discussions about this topic on quagga ml
> that show
> that everybody has a different opinion about this term ;-)

Are you referring to this thread?
https://lists.quagga.net/pipermail/quagga-dev/2014-November/011795.html

I could see differing opinions regarding the implementation of a VRF; is 
there really a controversy on what a VRF is?

David
