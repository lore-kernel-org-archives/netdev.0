From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] e1000: skb truesize fix
Date: Wed, 26 Apr 2006 06:16:25 -0400
Message-ID: <444F4879.2010801@pobox.com>
References: <20060426061229.25966.83974.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:18407 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751398AbWDZKQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 06:16:39 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060426061229.25966.83974.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Hi,
> 
> This patch was already merged in Jeff Garzik's netdev upstream branch but
> needs to go into 12.6.16.y and 2.6.17rc* as it fixes a critical buffersize
> skb bug that is exposed by an earlier patch by Dave Miller and Herbert
> Xiu. I'm therefore resending it:
> 
> Please apply to 2.6.16.y and queue for 2.6.17-rc.
> 
> These changes are available through git. Jeff, please pull from:
> 
> git://lost.foo-projects.org/~ahkok/git/linux-2.6 skb_truesize

pulled, queued for 2.6.17-rc


