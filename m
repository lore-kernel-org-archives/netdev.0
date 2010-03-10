From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH] can: bfin_can: switch to common
	Blackfin can header
Date: Wed, 10 Mar 2010 07:17:09 -0500
Message-ID: <8bd0f97a1003100417x6e9830dav949fd6b0511d99d0@mail.gmail.com>
References: <1268150589-27123-1-git-send-email-vapier@gentoo.org>
	<4B974D38.6000501@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	uclinux-dist-devel@blackfin.uclinux.org,
	"David S. Miller" <davem@davemloft.net>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f200.google.com ([209.85.210.200]:44845 "EHLO
	mail-yx0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab0CJMR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 07:17:29 -0500
Received: by yxe38 with SMTP id 38so1540418yxe.22
        for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 04:17:29 -0800 (PST)
In-Reply-To: <4B974D38.6000501@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 10, 2010 at 02:41, Wolfgang Grandegger wrote:
> Mike Frysinger wrote:
>> The MMR bits are being moved to this header, so include it.
>>
>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>
>
>> ---
>> note: this can be merged for 2.6.34 or 2.6.35
>
> Is it required to make the driver working under 2.6.34?

not for 2.6.34, but it will be for 2.6.35
-mike
