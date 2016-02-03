From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [PATCH net-next 6/6] e1000e: call ndo_stop() instead of
 dev_close() when running offline selftest
Date: Wed, 3 Feb 2016 09:13:45 +0100
Message-ID: <56B1B6B9.7020905@kpanic.de>
References: <1454408028-16986-1-git-send-email-sassmann@kpanic.de>
 <1454408028-16986-7-git-send-email-sassmann@kpanic.de>
 <56B0A843.9060703@kpanic.de>
 <20160202.162830.131864881309085395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from app1a.xlhost.de ([84.200.252.161]:55221 "EHLO app1a.xlhost.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755972AbcBCPWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 10:22:41 -0500
In-Reply-To: <20160202.162830.131864881309085395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.02.2016 22:28, David Miller wrote:
> 
> Always, when sending an updated version of a patch which is part of a
> series, always resubmit the entire series rather than just the patch
> which is changing.
> 
> Thanks.
> 

Sorry Dave, going to send out a complete V2 right away.

  Stefan
