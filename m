From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: stable bonding config
Date: Sat, 14 Jan 2012 13:51:07 +0100
Message-ID: <4F117A3B.9000405@gmail.com>
References: <CANj2Ebc8+Uu6gW8=Jsb42Cr2Ry88cvys-DZrkeX8Rh+uvAsRAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35705 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754627Ab2ANMut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 07:50:49 -0500
Received: by wibhm14 with SMTP id hm14so998781wib.19
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2012 04:50:47 -0800 (PST)
In-Reply-To: <CANj2Ebc8+Uu6gW8=Jsb42Cr2Ry88cvys-DZrkeX8Rh+uvAsRAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/01/2012 03:31, Simon Chen a =E9crit :
> Hi all,
>
> Not sure if this is the right place to ask, but I got very good
> answers about this topic in the past...
>
> I am mostly using Ubuntu 10.10. Each server has dual intel 10G NICs,
> which I want to bond. I configured the switches to support 802.3ad.
> Based on this post http://ubuntuforums.org/showthread.php?t=3D1595177=
, I
> configure the server as:

[snip]

Consider reading the documentations in /usr/share/doc/ifenslave-2.6/ an=
d the example files in the=20
examples subdirectory.

	Nicolas.
