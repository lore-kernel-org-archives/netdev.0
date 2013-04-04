From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] lib80211: make lib80211 can be enabled independently
Date: Thu, 04 Apr 2013 18:05:47 +0200
Message-ID: <1365091547.8229.2.camel@jlt4.sipsolutions.net>
References: <20130404160130.GA2577@udknight>
	 (sfid-20130404_180146_336133_A89725C9)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wang YanQing <udknight@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130404160130.GA2577@udknight> (sfid-20130404_180146_336133_A89725C9)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-04-05 at 00:01 +0800, Wang YanQing wrote:
> Current we can only enable lib80211 by enable a driver
> in tree use it which will select it, but some out tree's
> drivers also use it, so I think it has sense to make lib80211
> can be enabled independently.
> 
> A example of the out tree's drivers use lib80211 is:
> hybird driver(wl) for Broadcom Corporation BCM43225 802.11b/g/n

Tough luck.

NACK.

johannes
