From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] {cfg,mac}80211.h: fix some kernel-doc warnings
Date: Wed, 16 Jan 2013 15:11:41 +0100
Message-ID: <1358345501.22862.10.camel@jlt4.sipsolutions.net>
References: <1357995254-2318-1-git-send-email-yacine.belkadi.1@gmail.com>
	 (sfid-20130112_135436_590066_4364BBD9)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yacine Belkadi <yacine.belkadi.1@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357995254-2318-1-git-send-email-yacine.belkadi.1@gmail.com> (sfid-20130112_135436_590066_4364BBD9)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I totally missed your email before.

> Warning(include/net/cfg80211.h:334): No description found for return value of       'cfg80211_get_chandef_type'
> 
> These warnings are only reported when scripts/kernel-doc runs in verbose mode.
> 
> Fix:
> In comments, use "Return:" to describe function return values.

I wasn't even aware of this, is that new? Anyway, applied, thanks.

johannes
