From: Dominik Kubla <dominik.kubla@sciobyte.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 18 Aug 2003 15:40:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308181540.23709.dominik.kubla@sciobyte.com>
References: <20030728213933.F81299@coredump.scriptkiddie.org> <20030818044419.0bc24d14.davem@redhat.com> <20030818143401.1352d158.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: willy@w.ods.org, alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com,
   lamont@scriptkiddie.org, davidsen@tmr.com, bloemsaa@xs4all.nl,
   marcelo@conectiva.com.br, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephan von Krawczynski <skraw@ithnet.com>,
   "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030818143401.1352d158.skraw@ithnet.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Montag, 18. August 2003 14:34 schrieb Stephan von Krawczynski:

> David, this is the wrong way round. Others'/my question was not about t=
he
> implementation and technical considerations leading to it (bottom up), =
but
> pure and simple (and top down): what is the _positive_ outcome of this
> implementation compared to others? We are always talking of setups that
> seem to be more complicated because of the current situation. So one wo=
uld
> expect that there are advantages that make up the discussed disadvantag=
es.
> And since I obviously don't have the knowledge to see them, I'd like to
> learn and therefore ask: what are the advantages on the _users_ side?

Very simple: no need for any IPMP crap on Linux. It just works.  And that=
 puts=20
"answered" on all questions that were ever raised regarding that issue.

Regards,
  Dominik
--=20
ScioByte GmbH                     | ScioByte Information Technologies AG
Fritz-Erler-Strasse 6             | Innere G=FCterstrasse 4
55129 Mainz (Germany)             | 6304 Zug (Switzerland)
Phone: +49 700 724 629 83         | Phone: +41 41 710 30 18
Fax:   +49 700 724 629 84         |

GnuPG: 1024D/717F16BB A384 F5F1 F566 5716 5485  27EF 3B00 C007 717F 16BB
