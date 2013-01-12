From: Cedric Jehasse <cedric.jehasse@gmail.com>
Subject: Re: qmi_wwan on Huawei E398
Date: Sat, 12 Jan 2013 13:22:31 +0100
Message-ID: <CABvLYuB4bT+0rAYF=MbuR9DJ0UFTrOR5Sv63jr4Y9wxz9G4gFg@mail.gmail.com>
References: <CABvLYuAX=r_Y0AdDtNp5g0kRYeP6suhLe_b68a7sQYJ-i7wrvg@mail.gmail.com>
	<34bc2a91-d03c-4143-8194-5dbe3b55530a@email.android.com>
	<CAGOautsU-Hen5EP-Y3Xp+jzGYRJZQFCGRk=mt0MvH2GfpTQe4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org
To: Marius Kotsbak <marius@kotsbak.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f49.google.com ([209.85.212.49]:51576 "EHLO
	mail-vb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab3ALMWc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 07:22:32 -0500
Received: by mail-vb0-f49.google.com with SMTP id s24so1755991vbi.8
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 04:22:31 -0800 (PST)
In-Reply-To: <CAGOautsU-Hen5EP-Y3Xp+jzGYRJZQFCGRk=mt0MvH2GfpTQe4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Have you tried if the same happens with modemmanager?
>
No, i haven`t. And it's not really relevant for me, as modemmanager
might match interfaces in a different way.

It looked weird to me to have a single parent interface for both the
cdc_dwm device and the wwan device, while there are separate
usb_interfaces for control and data.
=46rom Bj=F8rn's explanation, i understand why this was done. And i wil=
l
take a look at how this can be changed in ofono.

Thanks,
Cedric
