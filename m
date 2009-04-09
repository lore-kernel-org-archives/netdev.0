From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: DSA drivers in net/ vs drivers/net/
Date: Thu, 9 Apr 2009 03:34:18 -0500
Message-ID: <A8EBEE37-E922-4A09-9325-EDA786031A29@kernel.crashing.org>
References: <53D98710-2AA9-42D8-A478-40B51303678B@kernel.crashing.org> <20090408101242.GZ4738@xi.wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47834 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753393AbZDIIeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2009 04:34:24 -0400
In-Reply-To: <20090408101242.GZ4738@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 8, 2009, at 5:12 AM, Lennert Buytenhek wrote:

> On Tue, Apr 07, 2009 at 11:58:05PM -0500, Kumar Gala wrote:
>
>> Lennert,
>
> Hi Kumar,
>
>
>> Was glancing over the DSA code and was wondering if there was any
>> reason we have the actual drivers for the various chips in net/ vs
>> drivers/net/dsa/
>
> No real good reason, I guess.  I'd be happy to move the individual
> chip drivers under drivers/net/dsa/.

Seems like a good think for .31

- k
