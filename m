From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH] veth: delay peer link configuration after interfaces are tied
Date: Mon, 30 May 2016 12:14:40 +0200
Message-ID: <874m9f4zu7.fsf@zoro.exoscale.ch>
References: <574C0697.6060506@6wind.com>
	<1464603132-24665-1-git-send-email-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:38938 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbcE3KWx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 06:22:53 -0400
In-Reply-To: <1464603132-24665-1-git-send-email-vincent@bernat.im> (Vincent
	Bernat's message of "Mon, 30 May 2016 12:12:12 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 30 mai 2016 12:12 CEST, Vincent Bernat <vincent@bernat.im>=C2=
=A0:

> When the peer link is created, its "iflink" information is not
[...]

And that's the wrong patch... Please, ignore this one.
--=20
Don't stop with your first draft.
            - The Elements of Programming Style (Kernighan & Plauger)
