From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 9/11] cxgb3 - engine microcode update
Date: Wed, 05 Sep 2007 09:00:04 -0500
Message-ID: <46DEB664.2090704@opengridcomputing.com>
References: <20070822034947.9404.87301.stgit@speedy5> <46D819CE.5050207@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([71.42.183.126]:33955 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756107AbXIEOAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 10:00:05 -0400
In-Reply-To: <46D819CE.5050207@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Jeff Garzik wrote:
> Divy Le Ray wrote:
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Load microcode engine when the interface
>> is configured up.
>> Bump up version to 1.1.0.
>> Allow the driver to be and running with
>> older microcode images.
>> Allow ethtool to log the microcode version.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> 
> ACK patches 9-14, but dropped, since they do not apply to #upstream 
> (probably due to fixes sent into 2.6.23-rc)
> 

Hey Jeff,

I think 9-14 still need to be incorporated.  I don't see them in your 
upstream branch, and they aren't in linus' tree either.

Steve.

