From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Rate limiting AP bandwidth change messages in
 ieee80211_config_bw?
Date: Wed, 30 Sep 2015 21:04:12 +0200
Message-ID: <1443639852.1859.25.camel@sipsolutions.net>
References: <CA+5PVA4yaLG2NtJ_Bg5-BQzR-Wa5ABxPb-cLxF7bjSsf-P1_5Q@mail.gmail.com>
	 (sfid-20150930_190254_762697_55F052FA) <1443637937.1859.19.camel@sipsolutions.net>
	 (sfid-20150930_203253_594716_3CF517AD)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: drago01 <drago01@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443637937.1859.19.camel@sipsolutions.net> (sfid-20150930_203253_594716_3CF517AD)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> I'm not sure ratelimiting it would even work - it's not *that* high
> frequency? Not really sure though.
> 
> I think we can do either, it's not such a terribly important message as
> far as I can tell.
> 

Seems like Emmanuel would like to see the message stay in some form -
perhaps we should try rate limiting it then? Could you check if that
actually works?

johannes
