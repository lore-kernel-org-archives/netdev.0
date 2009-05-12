From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 12 May 2009 20:00:15 +0200
Message-ID: <7e0dd21a0905121100l658867dds309dc1c4205d5058@mail.gmail.com>
References: <1242076914.12380.2.camel@bender>
	 <87octymhbt.fsf@basil.nowhere.org>
	 <7e0dd21a0905121058m1f894de6q9805e5392aef3aea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Christoph Lameter <cl@linux.com>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:51108 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbZELSAQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 14:00:16 -0400
Received: by bwz22 with SMTP id 22so130731bwz.37
        for <netdev@vger.kernel.org>; Tue, 12 May 2009 11:00:16 -0700 (PDT)
In-Reply-To: <7e0dd21a0905121058m1f894de6q9805e5392aef3aea@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andi,

> When you add new interfaces like this you should add them to the pack=
et (7)
> manpage too.

Currently, There is nothing in the manpage of packet(7) about RX_RING.
However I can start to write a summary=A0 that describes processes,
headers and statuses of both feature (RX_RING and TX_RING).
I think "Socket Options" section of packet(7) is appropriate.

Johann
