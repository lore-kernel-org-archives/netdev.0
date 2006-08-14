From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH wireless-dev] d80211: switch status codes, reason codes,
 and EIDs to enums
Date: Mon, 14 Aug 2006 09:54:18 +0200
Message-ID: <44E02C2A.2010701@sipsolutions.net>
References: <200608131243.51185.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:45020 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751923AbWHNHzV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 03:55:21 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200608131243.51185.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> +	WLAN_EID_QUIET = 40,
>   
I was about to send a patch fixing this as well :)
> +	WLAN_EID_IBSS_DFS = 41,
>  /* EIDs defined as part fo 11h - ends */
Care to fix the two occurrences of this typo in a respun patch? (should 
be 'of' instead of 'fo')
If you can't easily recreate that patch I'll send one after this goes in.

johannes
