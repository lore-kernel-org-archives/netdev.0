From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Wed, 19 Nov 2014 12:04:31 +0300
Message-ID: <546C5D1F.108@msgid.tls.msk.ru>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54363ED0.605@broadcom.com> <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com> <3543341.FmUQFH9nrl@eisbaer>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Seth Forshee <seth.forshee@canonical.com>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Maximilian Engelhardt <maxi@daemonizer.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJl?= =?UTF-8?B?Y2tp?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:56299 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753125AbaKSJEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 04:04:33 -0500
In-Reply-To: <3543341.FmUQFH9nrl@eisbaer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

18.11.2014 01:36, Maximilian Engelhardt wrote:
[]
> I just wanted to ask if there is any progress on this issue since I haven't 
> heard anything for a month. Please let me know if you need any additional 
> information.

I've no idea if there's any progress.  Meanwhile I've an easy way of
testing of my brcm4313 card in a mini-itx board with mini-PCIe slot.
It works rather nicely and the stalls are easy to trigger.
Running 3.16 kernel right now, tried to d/load a file from the
AP, -- boom, it stalled after 77Kb.

Since the previous discussion apparently ended prematurely and no patches
to try emerged, I don't have anything to try on it...

Thanks,

/mjt
