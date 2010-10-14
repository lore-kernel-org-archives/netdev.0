From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: dont use netdev_alloc_skb()
Date: Thu, 14 Oct 2010 20:17:35 +0200
Message-ID: <1287080255.22035.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <AANLkTi=NvnPov_=KQJz2uXt1R-ep4oahDF0J=3HwhGzG@mail.gmail.com>
 <1286860560.30423.186.camel@edumazet-laptop>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE4282DD@SJEXCHCCR02.corp.ad.broadcom.com>
 <20101014.103914.193713537.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1932 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512Ab0JNSR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 14:17:57 -0400
In-Reply-To: <20101014.103914.193713537.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-14 at 10:39 -0700, David Miller wrote:
> From: "Vladislav Zolotarov" <vladz@broadcom.com>
> Date: Tue, 12 Oct 2010 02:12:41 -0700
> 
> > Dave, if it can wait till tomorrow, I'd like to ask u to wait for Eilon's
> > final ACK.
> 
> Ok, but it is two days later now :-)
> 

I was under the impression that the current path is to revert
b30973f877fea1a3fb84e05599890fcc082a88e5 instead of the original thread.
Eric - do you still want to apply the original patch from this thread?

Thanks,
Eilon


