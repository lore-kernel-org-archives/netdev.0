From: Yacine Belkadi <yacine.belkadi.1@gmail.com>
Subject: Re: [PATCH] {cfg,mac}80211.h: fix some kernel-doc warnings
Date: Thu, 17 Jan 2013 23:13:25 +0100
Message-ID: <50F87785.6060302@gmail.com>
References: <1357995254-2318-1-git-send-email-yacine.belkadi.1@gmail.com>  (sfid-20130112_135436_590066_4364BBD9) <1358345501.22862.10.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	yacine.belkadi.1@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358345501.22862.10.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 01/16/2013 03:11 PM, Johannes Berg wrote:
> Hi,
> 
> I totally missed your email before.
> 
>> Warning(include/net/cfg80211.h:334): No description found for return value of       'cfg80211_get_chandef_type'
>>
>> These warnings are only reported when scripts/kernel-doc runs in verbose mode.
>>
>> Fix:
>> In comments, use "Return:" to describe function return values.
> 
> I wasn't even aware of this, is that new? Anyway, applied, thanks.

Yes, it's from December.
Here is the last thread: https://lkml.org/lkml/2012/11/26/709

Yacine
