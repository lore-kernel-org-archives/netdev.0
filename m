From: =?UTF-8?Q?Br=C3=A1ulio_Bhavamitra?= <braulio@eita.org.br>
Subject: Re: atl1c hangs still on 3.9.0
Date: Fri, 14 Jun 2013 14:06:04 -0300
Message-ID: <CAJri6_vhZG+MD-8TVA6+LL=zx6sbFTx_8mt3sCuVeXd_pvwCeQ@mail.gmail.com>
References: <CAJri6_uvJ--yGezQGTENzrd8VR1KOfMUj6tSDN70MJoGcXAQng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:42008 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550Ab3FNRGq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 13:06:46 -0400
Received: by mail-lb0-f182.google.com with SMTP id r11so793599lbv.41
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 10:06:44 -0700 (PDT)
In-Reply-To: <CAJri6_uvJ--yGezQGTENzrd8VR1KOfMUj6tSDN70MJoGcXAQng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it works pretty well with 3.6.9, the throughput is mucher high also.

On Fri, Jun 14, 2013 at 10:20 AM, Br=C3=A1ulio Bhavamitra
<braulio@eita.org.br> wrote:
> hello,
>
> I saw http://www.spinics.net/lists/netdev/msg228914.html and the
> problem persists on 3.9.0, ubuntu 13.04
>
> [  283.723684] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Down
> [  285.210649] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbp=
s
> Full Duplex>
> [  498.097358] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Down
> [  499.610475] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbp=
s
> Full Duplex>
> [  583.993662] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Down
> [  585.501609] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbp=
s
> Full Duplex>
>
> =E2=9E=9C  ~  uname -a
> Linux bhavamitra-1215N 3.9.0-030900-generic #201304291257 SMP Mon Apr
> 29 17:06:25 UTC 2013 i686 i686 i686 GNU/Linux
> =E2=9E=9C  ~
>
> Is there a more recent fix??
>
> regards,
> br=C3=A1ulio
