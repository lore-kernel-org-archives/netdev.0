From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [NETFILTER]: Fix skb->nf_bridge lifetime issues
Date: Mon, 20 Feb 2006 18:56:15 +0100
Message-ID: <1140458176.3031.1.camel@localhost.localdomain>
References: <43F97342.9050806@trash.net>  <43F98CEE.1080609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <43F98CEE.1080609@trash.net>
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

Op ma, 20-02-2006 te 10:33 +0100, schreef Patrick McHardy:
> Patrick McHardy wrote:
> > Bart, can you please have a look at this patch and ACK/NACK it?
> > We have a bugreport in the netfilter bugzilla of broken conntrack
> > with tunnels on top of bridge devices (#448), which should be cured
> > by this patch.

Looks fine to me. Nice work.

cheers,
Bart
