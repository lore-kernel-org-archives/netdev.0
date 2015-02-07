From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH next 5/6] bonding: Allow userspace to set macaddr on bonding-dev
Date: Fri, 6 Feb 2015 17:22:45 -0800
Message-ID: <CAHo-OowT60X4L1wN7Hp=SVmmt+QyKSKd1x6=4i8OtoR8OqY7Gw@mail.gmail.com>
References: <1423270316-9311-1-git-send-email-maheshb@google.com>
	<4192.1423272023@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:43061 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbbBGBWq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 20:22:46 -0500
Received: by labhv19 with SMTP id hv19so4443120lab.10
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 17:22:45 -0800 (PST)
In-Reply-To: <4192.1423272023@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding master's MAC address is visible to the entire L2 domain
while the LACP frames are link local.

Acked-by: Maciej =C5=BBenczykowski <maze@google.com>
