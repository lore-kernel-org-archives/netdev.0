From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] e1000: Update truesize with the length of the packet for packet split
Date: Thu, 27 Apr 2006 13:33:57 -0700
Message-ID: <20060427203357.GB6168@kroah.com>
References: <20060426061229.25966.83974.stgit@gitlost.site> <20060426061628.25966.93051.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, "Garzik, Jeff" <jgarzik@pobox.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Miller, David" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:24507 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751625AbWD0Uf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 16:35:29 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <20060426061628.25966.93051.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 25, 2006 at 11:16:29PM -0700, Kok, Auke wrote:
> 
> Update skb with the real packet size.
> 
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: John Ronciak <john.ronciak@intel.com>

queued to -stable.

thanks,

greg k-h
