From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 31 Jul 2008 01:47:38 -0300
Message-ID: <55u7m5-i63.ln1@tux.abusar.org.br>
References: <47EA0DAB.7080205@securenet.de>
	<200807111633.42514.thomas.jarosch@intra2net.com>
	<200807151347.23598.thomas.jarosch@intra2net.com>
	<200807151810.45942.thomas.jarosch@intra2net.com>
	<20080715153045.12efaea4@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2008 15:30:45 -0300
D=E2niel Fraga <fragabr@gmail.com> wrote:

> 	I'm using kernel 2.6.26 and the problem has gone. No stalled
> connections anymore. The problem was with 2.6.25 kernel only.
=09
	Sorry, I was wrong. In 2.6.26 the problem remains.

	Everyday my connection stalls to my NNTP server using 2.6.26
too. Before I just used a "nmap -sS server" and the connection would
come back, but now it doesn't work.

--=20
Linux 2.6.26: Rotary Wombat
http://u-br.net


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
