From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] bonding: various fixes for bonding, netpoll & netconsole
 (v3)
Date: Tue, 19 Oct 2010 13:21:43 +0800
Message-ID: <4CBD2AE7.9010302@redhat.com>
References: <1287021713-1750-1-git-send-email-nhorman@tuxdriver.com> <20101018.082529.115920035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070Ab0JSFRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 01:17:23 -0400
In-Reply-To: <20101018.082529.115920035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/10 23:25, David Miller wrote:
> From: nhorman@tuxdriver.com
> Date: Wed, 13 Oct 2010 22:01:48 -0400
>
>> Version 3, taking the following changes into account:
>   ...
>> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
>
> Applied, thanks Neil.

Hi, David,

Which tree do you apply this patchset to? I checked both net-2.6
and net-next-2.6, neither of them has these patches.

I have some patches based on these patches.

Thanks.
