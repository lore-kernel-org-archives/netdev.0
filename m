From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [bdschuym@pandora.be: Re: ipt_physdev.c alignment
 problems on parisc64]
Date: Wed, 3 Sep 2003 20:05:17 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030903200517.5b031fa4.davem@redhat.com>
References: <20030903162022.GI6405@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030903162022.GI6405@conectiva.com.br>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003 13:20:23 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> 	Yes, it makes ipt_pysdev.c compile on parisc, Dave, could you please
> apply it? Or perhaps wait for the netfilter patches, your call.

As I mentioned in another email, this patch can't be used, it
breaks in mixed 32/64 bit environments.
