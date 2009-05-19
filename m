From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [PATCH 1/1] be2net: add two new pci device ids to pci device
	table
Date: Tue, 19 May 2009 06:52:41 +0530
Message-ID: <20090519012239.GA25724@serverengines.com>
References: <20090518100807.GA22855@serverengines.com> <20090518.114302.134669848.davem@davemloft.net> <20090518223344.GA25192@serverengines.com> <20090518.153813.187765090.davem@davemloft.net>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:48426 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752116AbZESBWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 21:22:18 -0400
Content-Disposition: inline
In-Reply-To: <20090518.153813.187765090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David. I will check the other patch.

On 18/05/09 15:38 -0700, David Miller wrote:
> From: Ajit Khaparde <ajitk@serverengines.com>
> Date: Tue, 19 May 2009 04:03:46 +0530
> 
> > David, thanks for the reply. There is a slight sense of urgency to see this 
> > patch in the upstream kernel. Hence I am sending this patch which I have
> > spun again - against the net-2.6 tree. Please accept. I hope it applies this
> > time.
> 
> I'll apply this to net-2.6 sure, but I wasn't saying this
> patch didn't apply correctly.
> 
> I was talking about the patch that moved the NAPI stuff out the TX
> work stuff in this driver.  That's the patch that wouldn't apply
> correctly.
> 
> This one:
> 
> 	http://patchwork.ozlabs.org/patch/27312/
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
