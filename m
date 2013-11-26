From: Pablo Cholaky <mrwaltercool@gmail.com>
Subject: r8169 Wake on Lan
Date: Tue, 26 Nov 2013 14:23:36 -0300
Message-ID: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36550 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932362Ab3KZRX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:23:58 -0500
Received: by mail-wi0-f169.google.com with SMTP id hm6so6194565wib.2
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:23:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there:

I have a HP ENVY laptop with this RealTek, and my laptop don't have a
BIOS option to disable WOL. I'm currently using a script on start and
shutdown to disable WOL, but could you guys make a module param to
enable/disable WOL?

This freaking WOL eats a lot of battery on my laptop and my scripts
don't work when I'm using a hibernation or booting a Linux ISO per
example. I don't know really if many HP laptops have this RealTek, but
a lot of HP laptops have this annoying problem (just see on Google hp
WOL battery drain). Seems like HP is only giving a bios option to
enterprise, and for users let a OS dependent option (Windows will
disable on boot).


Thank you very much dudes ;)


-- 
Pablo Cholaky
Linux user and developer
Slash.cl Owner
Blablabla
