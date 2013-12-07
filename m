From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: connect to PHY and make use of PHY device
Date: Sat, 7 Dec 2013 10:09:55 +0100
Message-ID: <CACna6ryyzKo4mg9Y=sfuA4i_QJv_+cSNYwXsmfgWmO2UDDweWQ@mail.gmail.com>
References: <1386374035-31762-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>
To: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:62829 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181Ab3LGJJ5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 04:09:57 -0500
Received: by mail-oa0-f47.google.com with SMTP id k1so1907588oag.20
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 01:09:57 -0800 (PST)
In-Reply-To: <1386374035-31762-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/7 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> This change was successfully tested on BCM5357. I was able to
> autonegotiate 1000Mb/s full duplex, as well as force any of the
> 10/100/1000 half/full modes.

Today I've tested this patch on BCM4706 with out-of-tree b53 PHY
driver. It is still working, I can choose any speed on my PC.

So this patch should be good & safe for all users.
