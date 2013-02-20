From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/10] netfilter: make /proc/net/netfilter pernet
Date: Thu, 21 Feb 2013 00:13:12 +0100
Message-ID: <20130220231312.GB3875@localhost>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
 <20130207183318.GA18359@localhost>
 <51246EEA.5020301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lve@guap.ru
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51246EEA.5020301@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 20, 2013 at 02:36:26PM +0800, Gao feng wrote:
> > This doesn't belong here to x_tables, it should be place in
> > include/net/net_namespace.h.
> 
> Get it,will fix it in next version.

Thanks Gao.

> Should I wait for the nf-next being open again?

Yes.
