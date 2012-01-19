From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Netfilter: New target: RLOG
Date: Thu, 19 Jan 2012 10:26:16 +0100
Message-ID: <1326965176.2249.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326926610-17830-1-git-send-email-rw@linutronix.de>
	 <20120119091248.GA32391@1984> <4F17E0A4.9040004@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rostedt@goodmis.org
To: Richard Weinberger <rw@linutronix.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4F17E0A4.9040004@linutronix.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 19 janvier 2012 =C3=A0 10:21 +0100, Richard Weinberger a =C3=A9=
crit :

> Yeah, I could add --ring, --ring-size and --add-timestamp to LOG.
> What about a rlog_common.o which can be used by ipt_LOG and ip6t_LOG?
>=20

or merge ipt_LOG and ip6t_LOG into xt_LOG ?


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
