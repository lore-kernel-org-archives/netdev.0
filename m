From: =?ISO-8859-1?Q?Jean=2DBaptiste_Th=E9ou?= <jbtheou@gmail.com>
Subject: Questioning about DM9000 and link up delay
Date: Sat, 24 Dec 2011 00:46:03 +0100
Message-ID: <CAGdsSeALNsVhqXsn32MqvCiqRTavxnBQrVbdPjOOSt-FFDMrsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64061 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924Ab1LWXqZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 18:46:25 -0500
Received: by eaad14 with SMTP id d14so3066677eaa.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 15:46:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

I am working on a fast boot project and i have a "trouble" and i would
know if someone know more about this topic.

I have improve my boot time . But now i would like to add dhcp
capacity and i have a delay (~2 sec) between dm9000 loading and link
up message. I use kernel ip autoconfig (ip=3Ddhcp on boot cmd) to get
the IP adress.

I have try lot of things (Force media type, trace initcall, etc), but
i cannot find the source of this delay. I think it's a hardware delay,
but 2 second sound like to much for me.

Have you any idea where i can search ?

Hardware configuration :

Mini2440 board
Linux 2.6.32.2
DM9000 driver

Thanking you in advance.

--
Jean-Baptiste Th=E9ou,
