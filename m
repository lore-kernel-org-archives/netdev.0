From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Bridge extensions to iproute2
Date: Tue, 10 Jul 2012 14:38:25 -0700
Message-ID: <CAHo-Ooyk_=UYsEtz-y6hupCtMOgKz2DF+j1BOnSsmAfm-5Bkqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux NetDev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:35937 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247Ab2GJViZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 17:38:25 -0400
Received: by gglu4 with SMTP id u4so562286ggl.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 14:38:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can't quite seem to locate the bridge extensions to iproute2.

Mentioned for example at:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=b078f0df676233fc7ebc1ab270bd11ef5824bb64

I'm interested in finding a way to disable the stp and learning on a
bridge and manually from userspace configuring the mac forwarding
database.
[for basically a userspace STP implementation, which wouldn't actually
be a tree]

Can this be done?

Thanks,

- Maciej
