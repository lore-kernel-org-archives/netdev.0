From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Tue, 16 Sep 2003 17:57:50 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200309161757.50682.bdschuym@pandora.be>
References: <200309022116.41697.bdschuym@pandora.be> <20030916140621.GE810@obroa-skai.de.gnumonks.org> <20030916151533.GA28380@home.tig-grr.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Tom Marshall <tommy@home.tig-grr.com>,
	Harald Welte <laforge@netfilter.org>,
	"David S. Miller" <davem@redhat.com>, acme@conectiva.com.br,
	netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
In-Reply-To: <20030916151533.GA28380@home.tig-grr.com>
Content-Disposition: inline
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Tuesday 16 September 2003 17:15, Tom Marshall wrote:
> > But ipt_physdev is a 2.6ism, thus we can still introduce any
> > incompatibility... For me it's enough to be compatible within 2.4 or
> > within 2.6.x (once 2.6.0 is out).
>
> Noooo!  Please don't break compatibility for 2.6.  I really don't want to
> have separate /sbin/iptables-2.4 and /sbin/iptables-2.6 binaries.

2.4 hasn't got ipt_physdev
