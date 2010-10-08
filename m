From: Jason Glasgow <jglasgow@google.com>
Subject: Re: [PATCH v2] Add Qualcomm Gobi 2000 driver.
Date: Fri, 8 Oct 2010 12:18:01 -0700
Message-ID: <AANLkTi=JTYE1Xi=kOWercpUsMzNEz5ZL+BBF5N2dk=ZB@mail.gmail.com>
References: <20101008181851.GA27756@srcf.ucam.org>
	<20101008.115050.28825457.davem@davemloft.net>
	<AANLkTimbpPZt4FSeHDNcfuoYeKDYtV2YsLPxP-2ngELO@mail.gmail.com>
	<20101008.120205.70182089.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mjg59@srcf.ucam.org, ellyjones@google.com, netdev@vger.kernel.org,
	msb@google.com, olofj@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:42859 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937Ab0JHTSF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 15:18:05 -0400
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o98JI3oI016611
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 12:18:04 -0700
Received: from gxk6 (gxk6.prod.google.com [10.202.11.6])
	by kpbe11.cbf.corp.google.com with ESMTP id o98JI2DU024563
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 12:18:02 -0700
Received: by gxk6 with SMTP id 6so778853gxk.2
        for <netdev@vger.kernel.org>; Fri, 08 Oct 2010 12:18:01 -0700 (PDT)
In-Reply-To: <20101008.120205.70182089.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Yes, your concern is valid.  A distribution would have trouble
supporting this out of the box unless they negotiated with Qualcomm.
I believe that many years ago we had a similar situation with WiFi
devices and firmware.

I think the right thing to do is to encourage vendors to allow
redistribution of their firmware by showing them that the firmware is
already freely available on other platforms.

-Jason

On Fri, Oct 8, 2010 at 12:02 PM, David Miller <davem@davemloft.net> wro=
te:
>
> From: Jason Glasgow <jglasgow@google.com>
> Date: Fri, 8 Oct 2010 11:59:19 -0700
>
> > Firmware is available in Windows packages. =A0For example,
> >
> > DW5620 Mobile Broadband mini-card
> > http://support.dell.com/support/downloads/download.aspx?c=3Dus&cs=3D=
2684&l=3Den&s=3Dpub&releaseid=3DR275082&SystemID=3DLat_13&servicetag=3D=
4PLG5L1&os=3DW732&osl=3Den&deviceid=3D21977&devlib=3D0&typecnt=3D0&verc=
nt=3D2&catid=3D-1&impid=3D-1&formatcnt=3D0&libid=3D20&typeid=3D-1&datei=
d=3D-1&formatid=3D-1&source=3D-1&fileid=3D406043
> >
> > <http://support.dell.com/support/downloads/download.aspx?c=3Dus&cs=3D=
2684&l=3Den&s=3Dpub&releaseid=3DR275082&SystemID=3DLat_13&servicetag=3D=
4PLG5L1&os=3DW732&osl=3Den&deviceid=3D21977&devlib=3D0&typecnt=3D0&verc=
nt=3D2&catid=3D-1&impid=3D-1&formatcnt=3D0&libid=3D20&typeid=3D-1&datei=
d=3D-1&formatid=3D-1&source=3D-1&fileid=3D406043>The
> > problem is =A0that the firmware is non-redistributable, not non-dis=
tributable.
>
> So address my concern, how could a distribution support this device
> out of the box?
>
> I don't think it's possible.
