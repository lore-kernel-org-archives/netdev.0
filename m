From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] net: allow multiple rx_handler registration
Date: Tue, 12 Jul 2011 18:02:38 +0200
Message-ID: <CAHXqBFJ6mQkAgfSTOgPCjOaGBnC2HuZVL=Do=Zzd_nU6Yj+Jtw@mail.gmail.com>
References: <1310468761-2304-1-git-send-email-jpirko@redhat.com>
 <20110712115422.GD616804@jupiter.n2.diac24.net> <20110712132005.GA2300@minipsycho.brq.redhat.com>
 <20110712142937.GA909183@jupiter.n2.diac24.net> <20110712150120.GB2300@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net,
	greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:54248 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938Ab1GLQC7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 12:02:59 -0400
Received: by qyk9 with SMTP id 9so2898151qyk.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 09:02:58 -0700 (PDT)
In-Reply-To: <20110712150120.GB2300@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/12 Jiri Pirko <jpirko@redhat.com>:
> Tue, Jul 12, 2011 at 04:29:38PM CEST, equinox@diac24.net wrote:
>>P.S.: Could you please provide some sample usage cases for this featu=
re?
> Converting vlan to rx_handler needs this at least.

Do you already have some code for this? PoC quality maybe?

Best Regards,
Micha=B3 Miros=B3aw
