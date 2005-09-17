From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [HELP] netfilter Kconfig dependency nightmare
Date: Sat, 17 Sep 2005 12:32:31 -0300
Message-ID: <39e6f6c705091708323259f932@mail.gmail.com>
References: <20050916021451.3012196c.akpm@osdl.org>
	 <20050916191959.GN8413@sunbeam.de.gnumonks.org>
	 <39e6f6c705091617514457eded@mail.gmail.com>
	 <20050917012315.GA29841@mandriva.com>
	 <20050917080714.GV8413@sunbeam.de.gnumonks.org>
	 <Pine.LNX.4.61.0509171306290.3743@scrub.home>
	 <20050917112949.GZ8413@sunbeam.de.gnumonks.org>
	 <Pine.LNX.4.61.0509171407460.3743@scrub.home>
	 <20050917152931.GA8413@sunbeam.de.gnumonks.org>
Reply-To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751119AbVIQPcd@vger.kernel.org>
To: Harald Welte <laforge@netfilter.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>
In-Reply-To: <20050917152931.GA8413@sunbeam.de.gnumonks.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/17/05, Harald Welte <laforge@netfilter.org> wrote:
> On Sat, Sep 17, 2005 at 02:18:28PM +0200, Roman Zippel wrote:
> > Since IP_NF_CONNTRACK_NETLINK is the one creating the dependency,
> > something like this should work:
> 
> yes, I agree.  Looking at the behaviour of "menuconfig", I think your
> suggestion solves the problem.  I didn't try to compile all the
> combinations, though.
> 
> I'll submit a patch via DaveM soon.

OK, I'll test it as soon as it appears here :-)

- Arnaldo
