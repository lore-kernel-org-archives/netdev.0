From: "Gabor Z. Papp" <gzp@papp.hu>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.9
Date: Wed, 04 Aug 2010 19:23:05 +0200
Message-ID: <x6k4o69ts6@gzp>
References: <4C5832F9.50004@trash.net> <x6bp9jy7sj@gzp>
	<4C584C63.8010607@trash.net> <x6vd7rwrah@gzp> <x6lj8nwqu4@gzp>
	<alpine.LSU.2.01.1008032001430.1519@obet.zrqbmnf.qr> <x6sk2vo9eq@gzp>
	<alpine.LSU.2.01.1008032033200.6329@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter\@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jan Engelhardt <jengelh@medozas.de>:

| >| (BTW, with --disable-shared you remove the possibility to use any .so
| >| files whatsoever. You can use --enable-static --enable-shared to get
| >| both "all in one binary" and ".so support".)
| >
| >And how to force linking the binaries against the static libs?

| What libs?

Link iptables-multi against static versions of libip6tc and libxtables.
