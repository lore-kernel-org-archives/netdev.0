From: Cong Wang <cwang@twopensource.com>
Subject: Re: how to figure out which device a given IFB is connected to
Date: Mon, 15 Sep 2014 09:08:14 -0700
Message-ID: <CAHA+R7NxSY8fbAMLgekAxeN4n5U_NTKUczFRz9WUcY-xSHZTxw@mail.gmail.com>
References: <CBDE840F-96BA-4839-9774-86F72E99E964@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sebastian Moeller <moeller0@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:57406 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbaIOQIU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 12:08:20 -0400
Received: by mail-lb0-f181.google.com with SMTP id z11so4883622lbi.12
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 09:08:15 -0700 (PDT)
In-Reply-To: <CBDE840F-96BA-4839-9774-86F72E99E964@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 7:37 AM, Sebastian Moeller <moeller0@gmx.de> wr=
ote:
> I am looking for a way of doing the reverse,i.e.  figuring out for a =
given IFB if it is =E2=80=9Cconnected=E2=80=9D to a real interface and,=
 if yes, which interface. Basically, I want to recycle unused IFBs, but=
 want to make sure that they really are unused=E2=80=A6
>

There is no way to figure that out.
