From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [RFC] [PATCH 3/3] Kconfig update for regulatory domain
Date: Mon, 23 Oct 2006 18:04:55 -0700
Message-ID: <20061024010455.GB3552@devicescape.com>
References: <43e72e890610231551w5f5e947ena6d9a5d6f9a70ad9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:10183 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S964827AbWJXBE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 21:04:59 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Content-Disposition: inline
In-Reply-To: <43e72e890610231551w5f5e947ena6d9a5d6f9a70ad9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This last chunk is broken:
. . .
Hunk #2 FAILED at 90.


> --- wireless-dev-old/net/d80211/Kconfig	2006-10-23 13:56:11.000000000 -0400
> +++ wireless-dev/net/d80211/Kconfig	2006-10-23 17:04:12.000000000 -0400
> @@ -16,8 +90,6 @@ config D80211_LEDS
>  	This option enables a few LED triggers for different
>  	packet receive/transmit events.
>  
> -config D80211_
> -
>  config D80211_DEBUG
>  	bool "Enable debugging output"
>  	depends on D80211

