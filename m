From: Dragos Ilie <dragos.ilie@gmail.com>
Subject: IPv6 tc filters
Date: Mon, 11 Jun 2012 12:31:27 +0200
Message-ID: <CAOLNa-fyvic2xzrUwz2WsEap_CgGmU6OwAf=jMPCUVyXbrimVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39117 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab2FKKb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 06:31:27 -0400
Received: by yhmm54 with SMTP id m54so2356606yhm.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 03:31:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Do IPv6 tc filters work? According to Linux Advanced Routing & Traffic
Control HOWTO, IPv6 does not hook into the Routing Policy Database
(RPDB), thus causing the filters to fail. I would appreciate it if
someone on this list can confirm or refute this claim. If filters have
been fixed, since which kernel/iproute2 version do they work?

Regards,
Dragos
