From: Paul Moore <paul@paul-moore.com>
Subject: Re: NULL pointer deref, selinux_socket_unix_may_send+0x34/0x90
Date: Fri, 22 Mar 2013 14:24:46 -0400
Message-ID: <18436081.qYcpHKDzRW@sifl>
References: <CAMpz-8YY1ZFJnx5JAuGu3GBYhkbnYggEAqmVMQoHg7eqKNtyeg@mail.gmail.com> <3405435.XFBqjMtCVW@sifl> <CAMpz-8aJyEgesAYLgB3EPSCevDG5KcH+9S-sJUfBOnA0m_Ky1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eparis@redhat.com, sds@tycho.nsa.gov
To: =?utf-8?B?SsOhbiBTdGFuxI1law==?= <jan.stancek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:46288 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422877Ab3CVSYv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 14:24:51 -0400
Received: by mail-vc0-f177.google.com with SMTP id ia10so3356166vcb.36
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 11:24:50 -0700 (PDT)
In-Reply-To: <CAMpz-8aJyEgesAYLgB3EPSCevDG5KcH+9S-sJUfBOnA0m_Ky1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, March 22, 2013 05:52:37 PM J=C3=A1n Stan=C4=8Dek wrote:
> Paul,
>=20
> I applied your patch on top of 3.9-rc3 and ran v2 of reproducer. It
> hit the issue almost instantly:

Okay, thanks for trying it ... let me see what I can do.

--=20
paul moore
www.paul-moore.com
