From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [net-next PATCH v4 3/3] net: TCP thin dupack
Date: Thu, 18 Feb 2010 10:21:56 +0100
Message-ID: <4B7D06B4.60706@simula.no>
References: <4B7AAE6E.7080600@simula.no> <20100217.163338.54972301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de,
	ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:43909 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab0BRJWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 04:22:01 -0500
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1Ni2a7-00082t-PS
	for netdev@vger.kernel.org; Thu, 18 Feb 2010 10:21:59 +0100
In-Reply-To: <20100217.163338.54972301.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2010 01:33 AM, David Miller wrote:
> From: Andreas Petlund <apetlund@simula.no>
> Date: Tue, 16 Feb 2010 15:40:46 +0100
> 
>> Major changes:
>>       -Renamed variables, ioctl and sysctl.
>>       -Added sysctl documentation.
>>       -Removed redundant allocation
>>
>> Signed-off-by: Andreas Petlund <apetlund@simula.no>
> 
> Patches #2 and #3 look the same, what's going on here?
> 
> Thanks.

The changes from v3 to v4 was basically in the naming. I 
changed names for the given variables both for patch #2 and
patch #3. The removal of the unneeded allocation was also
done for both patches. It seems also I have forgotten to 
include the general patch description for each patch. I will
fix this for the next round of changes.

Cheers,
Andreas


