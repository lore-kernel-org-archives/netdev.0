From: Dongsoo Nathaniel Kim <dongsoo.kim@gmail.com>
Subject: Mainline kernel has problem with broadcom firmware
Date: Tue, 10 Jan 2012 10:12:47 +0900
Message-ID: <CAP+Vy9f0wMXebtfMWBXdC24cQR1d-2i6YZxfjK8JyOpVGgKvrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:51883 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932132Ab2AJBNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 20:13:09 -0500
Received: by obcwo16 with SMTP id wo16so4890475obc.19
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2012 17:13:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello folks,
After updating my kernel to 3.2 vanilla, I experienced a weird problem
with my broadcom ethernet card.
It seems to have some problem with firmware which is not placed in
kernel firmware directory.
When will it the correct firmware be available in the mainline?
bnx2-mips-09-6.2.1b.fw <= I mean this one.
I hacked bnx2 driver to use bnx2-mips-09-6.2.1a.fw and ethernet is
working, but we really need bnx2-mips-09-6.2.1b.fw, don't we?
Cheers,

Nate

--
=
Dongsoo Nathaniel Kim
Linux kernel, media device S/W engineer / Ph.D Student
Dept. of Computer Science, KAIST
Real-time & Embedded Systems Lab.
