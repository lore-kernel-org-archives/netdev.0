From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.4.x] IPv6 multicast (MLD,IGMP) code bypasses netfilter
 hooks
Date: Thu, 4 Dec 2003 10:37:19 -0800
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20031204103719.56038dba.davem@redhat.com>
References: <20031122090330.GB2745@obroa-skai.de.gnumonks.org>
	<20031123154344.3e2b0b1a.davem@redhat.com>
	<20031204090121.GD16635@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20031204090121.GD16635@obroa-skai.de.gnumonks.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Thu, 4 Dec 2003 14:31:21 +0530
Harald Welte <laforge@netfilter.org> wrote:

> Now that the other Dave's fix has made it in 2.6.0-test11, I have merged
> it (untested, but compiles) with 2.4.x.
> 
> Dave, would you consider applying this to to 2.4.x ?

Done, thanks for catching this Harald.
