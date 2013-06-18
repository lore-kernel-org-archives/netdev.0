From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Tue, 18 Jun 2013 19:04:47 +0200
Message-ID: <1371575087.22256.2.camel@jlt4.sipsolutions.net>
References: <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 <1361268221.8553.1.camel@jlt4.sipsolutions.net>
	 <1361290909.19353.140.camel@edumazet-glaptop>
	 <1361351538.8629.3.camel@jlt4.sipsolutions.net>
	 <1361351703.8629.5.camel@jlt4.sipsolutions.net>
	 <20130223061414.GA16883@merlins.org>
	 <1361912099.8440.21.camel@jlt4.sipsolutions.net>
	 <1371574361.3252.259.camel@edumazet-glaptop>
	 (sfid-20130618_185301_249353_52D357F3)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc MERLIN <marc@merlins.org>, David Miller <davem@davemloft.net>,
	Larry.Finger@lwfinger.net, bhutchings@solarflare.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	sgruszka@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:39703 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932860Ab3FRRFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 13:05:31 -0400
In-Reply-To: <1371574361.3252.259.camel@edumazet-glaptop> (sfid-20130618_185301_249353_52D357F3)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-18 at 09:52 -0700, Eric Dumazet wrote:

> > We'll be submitting a patch to make single pages default.
> 
> Do you think the same change would be possible for
> drivers/net/wireless/iwlegacy/4965-mac.c ?

Yes, Stanislaw?

johannes
