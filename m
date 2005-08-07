From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] add new nfnetlink_log subsystem
Date: Sun, 7 Aug 2005 23:55:03 +0200
Message-ID: <20050807215503.GJ10481@postel.suug.ch>
References: <20050730103005.GB6620@rama.de.gnumonks.org>
	<20050807112039.GF10481@postel.suug.ch>
	<20050807150358.GD4855@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
In-Reply-To: <20050807150358.GD4855@rama.de.gnumonks.org>
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

* Harald Welte <20050807150358.GD4855@rama.de.gnumonks.org> 2005-08-07 17:03
> On Sun, Aug 07, 2005 at 01:20:39PM +0200, Thomas Graf wrote:
> > Same very minor issues as nfnetlink regarding some of the
> > new netlink message construction policies. I'll "fix" them
> > during the conversion to the generic netlink attributes.
>=20
> is this supposed to happen soon?  I also need to update the userspace
> side in case you make any changes, so I'd appreciate any changes going
> in ASAP.  Alternatively just tell me what needs to change and I'll
> change it even before the generalization.

Within the next days. It is compatible to the old macros so
as long as we don't delete the old ones userspace can stay
as-is for the moment.
