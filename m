From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Wed, 19 Jun 2013 15:09:35 +0200
Message-ID: <20130619130935.GA2580@redhat.com>
References: <20130219040557.GB4778@merlins.org>
 <1361251033.19353.120.camel@edumazet-glaptop>
 <1361268221.8553.1.camel@jlt4.sipsolutions.net>
 <1361290909.19353.140.camel@edumazet-glaptop>
 <1361351538.8629.3.camel@jlt4.sipsolutions.net>
 <1361351703.8629.5.camel@jlt4.sipsolutions.net>
 <20130223061414.GA16883@merlins.org>
 <1361912099.8440.21.camel@jlt4.sipsolutions.net>
 <1371574361.3252.259.camel@edumazet-glaptop>
 <1371575087.22256.2.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Marc MERLIN <marc@merlins.org>,
	David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3422 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756468Ab3FSNIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 09:08:09 -0400
Content-Disposition: inline
In-Reply-To: <1371575087.22256.2.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 18, 2013 at 07:04:47PM +0200, Johannes Berg wrote:
> On Tue, 2013-06-18 at 09:52 -0700, Eric Dumazet wrote:
> 
> > > We'll be submitting a patch to make single pages default.
> > 
> > Do you think the same change would be possible for
> > drivers/net/wireless/iwlegacy/4965-mac.c ?
> 
> Yes, Stanislaw?

Yes, I'll post 4965 patch.

Thanks
Stanislaw
