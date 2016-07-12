From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 net] ipv6: addrconf: fix Juniper SSL VPN client regression
Date: Tue, 12 Jul 2016 15:56:22 +0200
Message-ID: <87h9bvot89.fsf@miraculix.mork.no>
References: <1468248230-5763-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Jonas Lippuner <jonas@lippuner.ca>,
	=?utf-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41192 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753236AbcGLN4h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 09:56:37 -0400
In-Reply-To: <1468248230-5763-1-git-send-email-bjorn@mork.no>
 (=?utf-8?Q?=22Bj=C3=B8rn?= Mork"'s
	message of "Mon, 11 Jul 2016 16:43:50 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes,

I just realized that I missed you on the CC list of the v2 patch. Sorry=
=2E
It was definitely not my intention. I really appreciate the feedback yo=
u
have kindly provided before.

I guess you might have seen it in netdev anyway, but in case not, here
is a direct patchwork link: http://patchwork.ozlabs.org/patch/646958/

I'll try to be less sloppy about CCs the next time, if we ever get to a
v3 of this. At the moment that requires figuring out what the actual
problem with the client is. Something I don't have the necessary tools
to do AFAICS.  So I will let the whole thing just sleep until there is
some more data about the Juniper client failure.


Bj=C3=B8rn
