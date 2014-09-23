From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 23 Sep 2014 18:28:54 +0400
Message-ID: <542183A6.4070207@msgid.tls.msk.ru>
References: <53FC1789.6020407@msgid.tls.msk.ru> <53FCA001.6090404@broadcom.com> <53FCB2A3.1050605@msgid.tls.msk.ru> <53FCFE1A.3060508@broadcom.com> <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com> <541EEF17.7020806@msgid.tls.msk.ru> <542145B1.4030202@msgid.tls.msk.ru> <54216BF1.3060500@broadcom.com> <20140923134419.GA19016@ubuntu-hedt> <54217AA5.2060803@broadcom.com> <542182BE.2000606@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>,
	Seth Forshee <seth.forshee@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:41445 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755725AbaIWO24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 10:28:56 -0400
In-Reply-To: <542182BE.2000606@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

23.09.2014 18:25, Michael Tokarev wrote:
> 23.09.2014 17:50, Arend van Spriel wrote:
>> On 09/23/14 15:44, Seth Forshee wrote:
[]
>>> It's been quite some time since I used them, but I think brcmsmac_tx is
>>> quite noisy so you may only want to enable that if you already suspect a
>>> tx problem. I always find it useful to enable the mac80211 and
>>> mac80211_msg events too when debugging wireless, and I often enable
>>> cfg80211 events as well (none of these are especially verbose).

mac80211_msg does not exist, it looks like.  fwiw.

/mjt
