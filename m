From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Mon, 17 Jan 2011 13:04:00 +0530
Message-ID: <AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com>
References: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com>
	<AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com>
	<20110116192017.GA3569@electric-eye.fr.zoreil.com>
	<AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63368 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab1AQHeB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 02:34:01 -0500
Received: by fxm20 with SMTP id 20so5654855fxm.19
        for <netdev@vger.kernel.org>; Sun, 16 Jan 2011 23:34:00 -0800 (PST)
In-Reply-To: <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 17, 2011 at 11:52 AM, Anand Raj Manickam <anandrm@gmail.com=
> wrote:
> Hi Romieu ,
> This is the dmesg =A0for XID
>
> eth0: RTL8168c/8111c at 0xf9628000, 00:17:54:00:f6:62, XID 1c4000c0 I=
RQ 31
> r8169: mac_version =3D 0x16
> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>
> Unfortunately , i m not able to upgrade my kernel now . If there is a
> Fix for it , that would be great !!
>
> Thanks for your kind reply ,
> Anand
>
>
>
> On Mon, Jan 17, 2011 at 12:50 AM, Francois Romieu <romieu@fr.zoreil.c=
om> wrote:
>> Anand Raj Manickam <anandrm@gmail.com> :
>> [...]
>>> This happens on a Linux 2.6.30.8 kernel .The driver is =A0in-kernel=
=2E
>>
>> I do not notice it with my 8168c (XID 18000000) on a modular 2.6.37-=
git.
>>
>> Can you send the XID of the r8169 that appears in the log of your ke=
rnel
>> and upgrade to a more recent kernel ?
>>
>> --
>> Ueimor
>>
>
