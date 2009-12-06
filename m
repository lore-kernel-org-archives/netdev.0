From: thomas yang <lampsu@gmail.com>
Subject: about routing
Date: Mon, 7 Dec 2009 00:40:25 +0800
Message-ID: <f4f837ab0912060840k4aa73c5br8703e2294a642e4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:35322 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755767AbZLFQkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 11:40:19 -0500
Received: by fxm5 with SMTP id 5so4122432fxm.28
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2009 08:40:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a Linux router with 3 interfaces eth0, wlan0, wlan1 (their IP
addresses 192.168.1.5/24,
192.168.2.5/24, 192.168.3.5/24).

I want to forward a packet (come in   from eth0,   its destination is
another network)   through wlan0 and wlan1 at the
same time,  then to different next hop.  Could you give me some ideas
to implement this?


--
Thomas
