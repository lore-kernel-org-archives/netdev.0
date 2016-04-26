From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 9/9] wireless: use nla_put_u64_64bit()
Date: Tue, 26 Apr 2016 09:51:31 +0200
Message-ID: <571F1E03.90703@6wind.com>
References: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461572722-6029-10-git-send-email-nicolas.dichtel@6wind.com>
 <1461656345.16188.6.camel@sipsolutions.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org,
	pshelar@nicira.com, aar@pengutronix.de, linux-wpan@vger.kernel.org,
	wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38101 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbcDZHvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 03:51:46 -0400
Received: by mail-wm0-f53.google.com with SMTP id u206so20963545wme.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 00:51:45 -0700 (PDT)
In-Reply-To: <1461656345.16188.6.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

Le 26/04/2016 09:39, Johannes Berg a =C3=A9crit :
> Hi Nicholas,
>=20
> Thanks for doing this.
>=20
> I'll also add a fix for the macro-generated nla_put_64() in
> nl80211_send_station(), unless there was a particular reason you didn=
't
> take that one?
>=20
> I suspect you just missed it while grepping, but wanted to ask.
Yes you're right. I missed it. Thank you for the check.

I will send the last patchset in some minutes.


Regards,
Nicolas
