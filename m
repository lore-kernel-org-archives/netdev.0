From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Netfilter: New target: RLOG
Date: Thu, 19 Jan 2012 10:46:02 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1201191045530.27900@frira.zrqbmnf.qr>
References: <1326926610-17830-1-git-send-email-rw@linutronix.de>  <20120119091248.GA32391@1984> <4F17E0A4.9040004@linutronix.de> <1326965176.2249.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Weinberger <rw@linutronix.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rostedt@goodmis.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1326965176.2249.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2012-01-19 10:26, Eric Dumazet wrote:

>Le jeudi 19 janvier 2012 =C3=A0 10:21 +0100, Richard Weinberger a =C3=A9=
crit :
>
>> Yeah, I could add --ring, --ring-size and --add-timestamp to LOG.
>> What about a rlog_common.o which can be used by ipt_LOG and ip6t_LOG=
?
>>=20
>
>or merge ipt_LOG and ip6t_LOG into xt_LOG ?

yes please :)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
