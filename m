From: =?UTF-8?Q?Br=C3=A1ulio_Bhavamitra?= <braulio@eita.org.br>
Subject: atl1c hangs still on 3.9.0
Date: Fri, 14 Jun 2013 10:20:44 -0300
Message-ID: <CAJri6_uvJ--yGezQGTENzrd8VR1KOfMUj6tSDN70MJoGcXAQng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:40310 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854Ab3FNNV0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 09:21:26 -0400
Received: by mail-la0-f52.google.com with SMTP id fo12so515544lab.25
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 06:21:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello,

I saw http://www.spinics.net/lists/netdev/msg228914.html and the
problem persists on 3.9.0, ubuntu 13.04

[  283.723684] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Down
[  285.210649] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps
=46ull Duplex>
[  498.097358] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Down
[  499.610475] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps
=46ull Duplex>
[  583.993662] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Down
[  585.501609] atl1c 0000:01:00.0: atl1c: eth0 NIC Link is Up<100 Mbps
=46ull Duplex>

=E2=9E=9C  ~  uname -a
Linux bhavamitra-1215N 3.9.0-030900-generic #201304291257 SMP Mon Apr
29 17:06:25 UTC 2013 i686 i686 i686 GNU/Linux
=E2=9E=9C  ~

Is there a more recent fix??

regards,
br=C3=A1ulio
