From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Remove netpoll blocking from uninit path
Date: Wed, 20 Oct 2010 01:45:38 -0700 (PDT)
Message-ID: <20101020.014538.193720733.davem@davemloft.net>
References: <1287507866-25156-1-git-send-email-nhorman@tuxdriver.com>
	<1287507866-25156-2-git-send-email-nhorman@tuxdriver.com>
	<4CBE9E7F.60107@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46683
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752328Ab0JTIpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 04:45:17 -0400
In-Reply-To: <4CBE9E7F.60107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 20 Oct 2010 15:47:11 +0800

> On 10/20/10 01:04, nhorman@tuxdriver.com wrote:
>> From: Neil Horman<nhorman@tuxdriver.com>
>>
>> Some recent testing in netpoll with bonding showed this backtrace
...
>> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> 
> Reviewed-by: WANG Cong <amwang@redhat.com>

Applied.

Neil, please add proper subsystem prefixes to your subject
lines, I've had to add them by hand as I add your patches.

Thanks.
