From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, PATCH 5/5]: netfilter+ipsec - policy checks
Date: Fri, 19 Mar 2004 17:24:05 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <405B1EA5.3030701@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au>	<404C874D.4000907@trash.net>	<20040308115858.75cdddca.davem@redhat.com>	<4059CF27.4030803@trash.net> <20040318221904.45011167.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au,  netdev@oss.sgi.com,
 netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040318221904.45011167.davem@redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> Other than the minor comments I've made the most unhappy I am
> with the input patch, and you agree it's grotty too.  Let's look
> for a better solution, perhaps with new top-level SKB state,
> and then we can put all of your work in after you're made the other
> minor fixes I've asked for as well.

I'm going to make the changes you suggested. Can you please explain what
you imagine with the new top-level skb state ?

Regards
Patrick
