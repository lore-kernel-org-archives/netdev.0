From: michael@albog.dk
Subject: Fwd: Question about kernel and IPv6...
Date: Wed, 23 Oct 2002 10:05:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035360350.3db6585e0bdce@webmail.debianlinux.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Cox have recommended my to forward my questions to you, hope you wil=
l help=20
me!

Read the following:

----- Videresendt meddelelse fra michael@albog.dk -----
    Dato: Wed, 23 Oct 2002 09:42:51 +0200
    Fra: michael@albog.dk
Reply-To: michael@albog.dk
 Emne: Question about kernel and IPv6...
      Til: Alan Cox <alan@redhat.com>

To Alan Cox!

Hi Alan,

I am working on a master thesis called =93Internet Protocol version 6=94.

In the project I have to setup a test-network for analyzing the RIPng pro=
tocol=20
etc. I am using four normal Intel PC=92s each running Debian Linux, with =
a custom=20
compiled kernel 2.4.19 downloaded from www.kernel.org. Two of the PC=92s =
are=20
running as a software-based router (using Zebra 0.92a-6), and the other i=
s=20
separately working as a client and server, respectively connect to router=
1 and=20
router2.

My problem is when I try to send an ICMPv6 request via the WAN-link (rout=
er1=20
and router2) from the client, I not getting any response from server. The=
=20
problem only appears when I try making a connection via the WAN-link, and=
 not=20
from router1<->server and router2<->client.

My question is:

- Could a problem be due to a wrong kernel-configuration? (I can attach=20
the .config if you are interested).

- What "kernel mechanism" is responsible for routing/transporting data be=
tween=20
two interfaces? (I think that=92s the problem in router1 and router2. Zeb=
ra is=20
only exchanging the "IPv6 kernel routing information" between router1 and=
=20
router2, and it is working fine).

- What kernel version have most IPv6 features build-in ?? (Maybe a featur=
e is=20
missing in 2.4.19. I have read an article about patching the kernel:=20
http://project6.ferrara.linux.it/papers/best_ipv6_support_4_linux/best_ip=
v6_supp
ort_4_linux.html, it is necessary?).

I hope you understand what my main problem is =96 English is not my prima=
ry=20
language.

I have got many information from mailinglists, messagesboards and homepag=
es,=20
but the main problem is, that those information is conflicting. That=92s =
why I=20
writing to the Linux Guru him self.=20

Btw. You are doing a very good job with the Linux kernel!

Best regards,

Michael Olsen

Atkins Danmark A/S, Tele=20
Pilestr=E6de 58
DK-1112 K=F8benhavn K
Telefon: +45 8233 9154
Fax:     +45 8233 9017

----- Slut af videresendt meddelelse -----
