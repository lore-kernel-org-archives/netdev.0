From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] tipc: use kfree_skb() instead
	of kfree()
Date: Tue, 23 Aug 2016 23:00:35 -0700 (PDT)
Message-ID: <20160823.230035.1705446489596549151.davem@davemloft.net>
References: <1471993262-4061-1-git-send-email-weiyj.lk@gmail.com>
	<25A14D9CFAB7B34FB9440F90AFD35233010193E3DF@ALA-MBA.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, weiyongjun1@huawei.com, weiyj.lk@gmail.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: Ying.Xue@windriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <25A14D9CFAB7B34FB9440F90AFD35233010193E3DF@ALA-MBA.corp.ad.wrs.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: "Xue, Ying" <Ying.Xue@windriver.com>
Date: Wed, 24 Aug 2016 02:47:32 +0000

> Acked-by: Ying Xue <ying.xue@windriver.com>

Please do not ACK patches like this.

If you quote the patch with no demarcation in the initial column for
the quoted text, like so:

> From: Wei Yongjun [mailto:weiyj.lk@gmail.com] 
> Sent: Wednesday, August 24, 2016 7:01 AM
> To: Jon Maloy; Xue, Ying; David S. Miller
> Cc: Wei Yongjun; netdev@vger.kernel.org; tipc-discussion@lists.sourceforge.net
> Subject: [PATCH -next] tipc: use kfree_skb() instead of kfree()
> 
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Use kfree_skb() instead of kfree() to free sk_buff.
 ...

then it makes it look like _you_ are posting this patch, so it ends up
again in patchwork and your ACK gets lost.

I truly feel like I've told you this at least one time already before,
so please fix your quoting so that it adheres to the list posting
standards used by everyone else here.

Thank you.

------------------------------------------------------------------------------
