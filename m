From: "Gabor Z. Papp" <gzp@papp.hu>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.9
Date: Tue, 03 Aug 2010 20:09:33 +0200
Message-ID: <x6sk2vo9eq@gzp>
References: <4C5832F9.50004@trash.net> <x6bp9jy7sj@gzp>
	<4C584C63.8010607@trash.net> <x6vd7rwrah@gzp> <x6lj8nwqu4@gzp>
	<alpine.LSU.2.01.1008032001430.1519@obet.zrqbmnf.qr>
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

| (BTW, with --disable-shared you remove the possibility to use any .so
| files whatsoever. You can use --enable-static --enable-shared to get
| both "all in one binary" and ".so support".)

And how to force linking the binaries against the static libs?

| The following changes since commit 371cea299f0b2eb100b9fc9fb99089640d2d606f:

|   xtables: remove unnecessary cast (2010-08-03 19:56:11 +0200)

| are available in the git repository at:
|   git://dev.medozas.de/iptables master

Fixed, compiled fine.
