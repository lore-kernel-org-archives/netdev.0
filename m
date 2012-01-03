From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [PATCH 1/2] net: phy: smsc: Move SMSC PHY constants to <linux/smscphy.h>
Date: Wed, 4 Jan 2012 00:29:24 +0100
Message-ID: <CAAwP0s12yzP9rDLYg76RCB+4EaVByOg_GU_CgghGUB_OSHDAjA@mail.gmail.com>
References: <1325524131-14585-1-git-send-email-martinez.javier@gmail.com> <20120103.134549.1973511401092214707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve.glendinning@smsc.com, ben@decadent.org.uk,
	eballetbo@iseebcn.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:60158 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312Ab2ACX3q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 18:29:46 -0500
Received: by ghbg21 with SMTP id g21so3729750ghb.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 15:29:45 -0800 (PST)
In-Reply-To: <20120103.134549.1973511401092214707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2012 at 7:45 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Javier Martinez Canillas <martinez.javier@gmail.com>
> Date: Mon, =C2=A02 Jan 2012 18:08:50 +0100
>
>> +/******************************************************************=
*********
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License
>> + * as published by the Free Software Foundation; either version 2
>> + * of the License, or (at your option) any later version.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See t=
he
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA =C2=A0=
02111-1307, USA.
>> + *
>> + ******************************************************************=
*********/
>
> Come on, I normally don't get into how people do copyrights in files,
> but this is a file with 13 trivial defines, and the whole kernel
> source tree is explicitly GPL V2'd by the top-level COPYING file.
>
> So this thing is over the top.

Ok, I'll remove the license from the file.

Thanks

--=20
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
Barcelona, Spain
