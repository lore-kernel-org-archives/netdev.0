From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/9] ixgb: driver update to 1.0.104-k2
Date: Tue, 23 May 2006 14:42:38 -0400
Message-ID: <4473579E.5070906@pobox.com>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55235 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932255AbWEWSml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 14:42:41 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Hi,
> 
> This is a resend/updated set of patches for ixgb. They were originally
> sent earlier on 2005-04-21 by Jeff Kirsher. Some modifications were made
> after comments, and this series does not include 2 of the patches sent
> at that time (I will resend those modified later).
> 
> Summary:
> 
> [1] fix rare early tso completion
> [2] remove duplicate code setting duplex and speed
> [3] fix flow control
> [4] add NETIF_F_LLTX analogous to e1000
> [5] add copper 10gig driver id
> [6] remove hardcoded number
> [7] use DPRINTK and msglvl, and ethtool to control it
> [8] add tx timeout counter
> [9] increment version to 1.0.104-k2
> 
> 
> These changes are available through git.
> 
> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 ixgb-1.0.104-k2
> 
> these patches are against
>  netdev-2.6#upstream 4e3ceac609cce39cb96e0eb8604934592371ed8c

pulled, thanks


