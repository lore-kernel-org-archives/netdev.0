From: Patrizio Bassi <patrizio.bassi@gmail.com>
Subject: (unknown)
Date: Mon, 09 Jul 2007 08:12:37 +0200
Message-ID: <4691D1D5.6030904@gmail.com>
Reply-To: patrizio.bassi@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.177]:26274 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbXGIGMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 02:12:41 -0400
Received: by ik-out-1112.google.com with SMTP id b32so448202ika
        for <netdev@vger.kernel.org>; Sun, 08 Jul 2007 23:12:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

after some email exchange with Stephen Hemminger i decide to forward the question to netdev ml.

I'm using vmware 6 and bridged networking with interface eth1 (sky2 driver).

The brigde works only when eth1 has the physical connection enabled (another pc plugged in), so
i always need to have another pc running to have virtual networking.
with tcpdump i can see packets coming from virtual machines, but none
sent back.

With other drivers (some old 3com cards) i don't have this issue.

I wonder if it's possibile to have the sky2 interface always "alive" (as
ifconfig reports it up) in order to have the bridge working.
I looked for some ethtool options...but nothing...

i saw in the code the queue disable, but i would like to switch this
somehow runtime...

thanks for support

Patrizio

ps. please CC me i'm not subscribed.


