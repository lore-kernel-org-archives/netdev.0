From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v7 4/9] bgmac: simplify/optimize rx DMA error handling
Date: Tue, 14 Apr 2015 12:36:10 +0200
Message-ID: <CACna6ryAVKx3nnDxJCyO_gsA8yDTvp5a2_-qQoNLNwSdJMNisw@mail.gmail.com>
References: <1429006082-23489-1-git-send-email-nbd@openwrt.org>
	<1429006082-23489-4-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:32963 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbbDNKgL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 06:36:11 -0400
Received: by iebmp1 with SMTP id mp1so11153795ieb.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 03:36:11 -0700 (PDT)
In-Reply-To: <1429006082-23489-4-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 12:07, Felix Fietkau <nbd@openwrt.org> wrote:
> Allocate a new buffer before processing the completed one. If allocat=
ion
> fails, reuse the old buffer.
>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
