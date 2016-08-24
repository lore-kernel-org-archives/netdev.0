From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] tipc: use kfree_skb() instead
	of kfree()
Date: Tue, 23 Aug 2016 23:08:53 -0700 (PDT)
Message-ID: <20160823.230853.1042343386041585627.davem@davemloft.net>
References: <1471993262-4061-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, weiyongjun1@huawei.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1471993262-4061-1-git-send-email-weiyj.lk@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 23 Aug 2016 23:01:02 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Use kfree_skb() instead of kfree() to free sk_buff.
> 
> Fixes: 0d051bf93c06 ("tipc: make bearer packet filtering generic")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied, thanks.

------------------------------------------------------------------------------
