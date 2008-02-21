From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NETFILTER]: fix ebtable targets return
Date: Wed, 20 Feb 2008 21:45:33 -0800 (PST)
Message-ID: <20080220.214533.205446881.davem@davemloft.net>
References: <12035721921230-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: joonwpark81@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <12035721921230-git-send-email-joonwpark81@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joonwoo Park <joonwpark81@gmail.com>
Date: Thu, 21 Feb 2008 14:36:32 +0900

> The function ebt_do_table doesn't take NF_DROP as a verdict from the targets.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

Whoops, good catch :-)

Patrick, if you want you can just signoff on this and I can
put it directly into my tree.
