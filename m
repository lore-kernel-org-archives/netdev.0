From: Mitar <mmitar@gmail.com>
Subject: [ANN] Tunneldigger, the new VPN solution
Date: Sat, 6 Jul 2013 16:06:04 -0700
Message-ID: <CAKLmikNRgYhOwS5GHYxphXuhPKoba7Td-cCGCpCp_KmEGK9uYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:59240 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab3GFXGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jul 2013 19:06:06 -0400
Received: by mail-qc0-f176.google.com with SMTP id z10so1707526qcx.21
        for <netdev@vger.kernel.org>; Sat, 06 Jul 2013 16:06:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I noticed that people on this list might be interested in the
following open source broker for L2TPv3 tunnels for Linux:

https://wlan-si.net/blog/2012/10/29/tunneldigger-the-new-vpn-solution/
https://github.com/wlanslovenija/tunneldigger

We developed it to make easy to maintain a large number of L2TPv3
tunnels. It is used in our community wireless network where WiFi nodes
also create tunnels to central servers for additional redundancy. So
the idea is that client side has to run on very limited embedded
devices (OpenWrt) while server side can use normal Linux server.
Additionally, it has to work over NATs and other things in between. It
supports also bandwidth limiting (in both directions).

Broker uses a custom and simple protocol and not a standard one.

I am not sure how much it is useful to others, but I hope it might be.
For us it works great!


Mitar
http://mitar.tnode.com/
