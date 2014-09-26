From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Fri, 26 Sep 2014 18:26:01 +0400
Message-ID: <54257779.8010903@msgid.tls.msk.ru>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com> <541EEF17.7020806@msgid.tls.msk.ru> <542145B1.4030202@msgid.tls.msk.ru> <54216BF1.3060500@broadcom.com> <20140923134419.GA19016@ubuntu-hedt> <54217AA5.2060803@broadcom.com> <542182BE.2000606@msgid.tls.msk.ru> <542183A6.4070207@msgid.tls.msk.ru> <20140923143124.GC19016@ubuntu-hedt> <54219984.2080601@msgid.tls.msk.ru> <5421AF5C.6000106@broadcom.com> <5421B78E.4050908@msgid.tls.msk.ru> <5422C6E0.3080002@broadcom.com> <8d3f6516-9578-406c-9444-6fe1ba982ea6@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Seth Forshee <seth.forshee@canonical.com>,
	brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:34732 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754693AbaIZO0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 10:26:05 -0400
In-Reply-To: <8d3f6516-9578-406c-9444-6fe1ba982ea6@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Okay, so finally, today, without any updates from your side,
I opened up the laptop again and inserted a newly bought
Intel 6235ANHMW card instead of this creaky brcm4313.  This
card works right out of the box - plug it in and set up,
both wifi and bluetooth (I had numerous probs with bluetooth
too with brcm card), and it works on both 2.4GHz and 5GHz
bands.  Connection is very good and stable, I wasn't able
to trigger a single glitch no matter how hard I tried.

My only sorry is a lot of wasted time, efforts and money -
all that have much better value than trying to deal with
non-working drivers.  And my only wish is so vendors stop
using non-working parts in their hardware.. But oh well.

Thanks,

/mjt
