From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH V2] bgmac: Clean warning messages
Date: Sat, 7 Mar 2015 12:28:17 +0100
Message-ID: <CACna6rz=QTVUnQaR-r4+NpBmQGSpmYS4StgL1eW4gB5q+DcZ4Q@mail.gmail.com>
References: <1425726626-31785-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	w-lkml@lebenslange-mailadresse.de, Joe Perches <joe@perches.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:43852 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbbCGL2S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 06:28:18 -0500
In-Reply-To: <1425726626-31785-1-git-send-email-peter.senna@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 March 2015 at 12:10, Peter Senna Tschudin <peter.senna@gmail.com> =
wrote:
> On my test environment the throughput of a file transfer drops
> from 4.4MBps to 116KBps due the number of repeated warning
> messages. This patch removes the warning messages as DMA works
> correctly with addresses using 0xC0000000 bits.
>
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
