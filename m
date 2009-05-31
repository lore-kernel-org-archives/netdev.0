From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/3] isdn: rename capi_ctr_reseted() to capi_ctr_down()
Date: Sun, 31 May 2009 07:19:41 +0200
Message-ID: <1243747181.3523.36.camel@localhost.localdomain>
References: <20090531-patch-00.tilman@imap.cc>
	 <20090531-patch-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Karsten Keil <karsten-keil@t-online.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:35886 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbZEaFUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 01:20:22 -0400
In-Reply-To: <20090531-patch-01.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tilman,

> Change the name of the Kernel CAPI exported function capi_ctr_reseted()
> to something representing its purpose better.
> 
> Impact: function renamed, no functional change
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> ---
>  Documentation/isdn/INTERFACE.CAPI |    4 ++--
>  drivers/isdn/capi/kcapi.c         |    8 ++++----
>  drivers/isdn/hardware/avm/b1.c    |    2 +-
>  drivers/isdn/hardware/avm/b1dma.c |    2 +-
>  drivers/isdn/hardware/avm/c4.c    |    4 ++--
>  drivers/isdn/hardware/avm/t1isa.c |    2 +-
>  drivers/isdn/hysdn/hycapi.c       |    4 ++--
>  include/linux/isdn/capilli.h      |    2 +-
>  net/bluetooth/cmtp/capi.c         |    2 +-
>  9 files changed, 15 insertions(+), 15 deletions(-)

for the Bluetooth part:

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


