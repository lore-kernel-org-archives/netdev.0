From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth: updated phy errata
Date: Fri, 04 Sep 2009 13:22:06 -0400
Message-ID: <4AA14CBE.8000402@nvidia.com>
References: <4A9C57F5.10800@nvidia.com>	<20090902.232201.248326790.davem@davemloft.net>	<4AA11CE7.7050400@nvidia.com> <20090904.150015.247320928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "manfred@colorfullife.com" <manfred@colorfullife.com>,
	"akpm@osdl.org" <akpm@osdl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:2517 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934384AbZIDWsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 18:48:43 -0400
In-Reply-To: <20090904.150015.247320928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: Ayaz Abdulla <aabdulla@nvidia.com>
> Date: Fri, 04 Sep 2009 09:57:59 -0400
> 
> 
>>Unfortunately, the phy vendors don't want us exposing the meaning of
>>their non-standard bits.
> 
> 
> So when you go away and some other developer tries to debug a problem
> in this area, then what happens?  Do they just guess what those bits
> mean?

I understand your concern. However, NVIDIA will always be the maintainer 
for these phy erratas and work with users to solve any issues. We have 
access to the confidential documents provided by the vendors.

Phy vendors have said "No" in the past. I can request for 'opening up' 
the bits again, but not all vendors will comply - resulting in no 
support for forcedeth. This is currently the only way to provide a good 
experience for the end user.

> 
> Sorry, this sort of situation is unacceptable in this modern day and
> age.  You'll need to work this out before I'm willing to take the
> patch.

