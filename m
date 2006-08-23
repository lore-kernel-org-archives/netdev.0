From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211:  get rid of sta_aid in favour of keeping track
	of TIM
Date: Wed, 23 Aug 2006 12:05:53 +0200
Message-ID: <1156327553.3914.6.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075200.055344487@sipsolutions.net>
	 <20060822203647.5a160a34@griffin.suse.cz>  <1156327454.3914.4.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56793 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964808AbWHWKFU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 06:05:20 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <1156327454.3914.4.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-23 at 12:04 +0200, Johannes Berg wrote:

> +/* miscellaneous IEEE 802.11 constants */
>  #define IEEE80211_MAX_FRAG_THRESHOLD 2346
>  #define IEEE80211_MAX_RTS_THRESHOLD 2347
> +#define IEEE80211_MAX_TIM_LEN 251

Nice, but I'm using it wrongly :) I'll send a fixed patch.

johannes
