From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH] add bridging support to nfnetlink_{log,queue}
Date: Tue, 09 Aug 2005 06:54:18 +0000
Message-ID: <1123570458.3385.4.camel@localhost.localdomain>
References: <W911141491296841123491979@kostunerix.telenet-ops.be>
	<20050808132413.GA25303@rama.de.gnumonks.org>
	<1123523010.3384.19.camel@localhost.localdomain>
	<20050808173610.GN25303@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "bdschuym@pandora.be" <bdschuym@telenet.be>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050808173610.GN25303@rama.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Op ma, 08-08-2005 te 19:36 +0200, schreef Harald Welte:
> > then the physindev should still be filled in if ebt_ulog is used. I'm
> > afraid this will result in more ugly ifdef's.
> 
> well, If you can send me a patch for those ugly ifdef's after you get
> back from holidays, I'll apply it.  Until then I think we can live
> without that missing bit.

Perhaps I'd better wait then until I have access to the latest changes.
Transparency never has been the greatest asset of the netfilter
development.

cheers,
Bart
