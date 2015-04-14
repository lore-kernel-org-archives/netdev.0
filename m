From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v6 5/9] bgmac: add check for oversized packets
Date: Tue, 14 Apr 2015 07:56:47 +0200
Message-ID: <CACna6rxjSsEVZc66kW918QLSaWfHtqBkrxf29MsOzuKeFjVF8w@mail.gmail.com>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
	<1428968537-6181-5-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:33147 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbbDNF4s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 01:56:48 -0400
Received: by layy10 with SMTP id y10so73874271lay.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 22:56:47 -0700 (PDT)
In-Reply-To: <1428968537-6181-5-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
> In very rare cases, the MAC can catch an internal buffer that is bigg=
er
> than it's supposed to be. Instead of crashing the kernel, simply pass
> the buffer back to the hardware
>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
