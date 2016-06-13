From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] ovs/vxlan: fix rtnl notifications on iface
 deletion
Date: Mon, 13 Jun 2016 10:12:14 +0200
Message-ID: <575E6ADE.2060007@6wind.com>
References: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com>
 <CAEh+42iyQ-O8QMRkN1T_kp5n3r4HJ8RBL9r6r+cvWK45MA6svg@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35047 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964820AbcFMIMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 04:12:18 -0400
Received: by mail-wm0-f47.google.com with SMTP id v199so66526824wmv.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 01:12:17 -0700 (PDT)
In-Reply-To: <CAEh+42iyQ-O8QMRkN1T_kp5n3r4HJ8RBL9r6r+cvWK45MA6svg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/06/2016 19:52, Jesse Gross a =C3=A9crit :
[snip]
> Does Geneve need this as well?
>=20
Yes, will fix it.


Thank you,
Nicolas
