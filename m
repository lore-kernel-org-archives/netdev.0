From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v7 1/9] bgmac: simplify tx ring index handling
Date: Tue, 14 Apr 2015 12:29:52 +0200
Message-ID: <CACna6rzchwt1i0reSVOhBZqL0fpR75KzjD5PYrqKDgXFmnP9FA@mail.gmail.com>
References: <1429006082-23489-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36147 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbbDNK3x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 06:29:53 -0400
Received: by iebrs15 with SMTP id rs15so10951277ieb.3
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 03:29:52 -0700 (PDT)
In-Reply-To: <1429006082-23489-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 12:07, Felix Fietkau <nbd@openwrt.org> wrote:
> Keep incrementing ring->start and ring->end instead of pointing it to
> the actual ring slot entry. This simplifies the calculation of the
> number of free slots.
>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
