From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the ftrace tree with the net-next
 tree
Date: Tue, 14 Apr 2015 23:24:40 -0400 (EDT)
Message-ID: <20150414.232440.5065499008228520.davem@davemloft.net>
References: <20150413175224.73a9baff@canb.auug.org.au>
	<20150415112323.057080ad@canb.auug.org.au>
	<20150414230629.78b83480@grimm.local.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	emmanuel.grumbach@intel.com
To: rostedt@goodmis.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150414230629.78b83480@grimm.local.home>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 14 Apr 2015 23:06:29 -0400

> I also noted this coming conflict in my pull request. So Linus should
> be very well aware of it.
> 
>  https://lkml.org/lkml/2015/4/13/652
> 
> "Also there's a conflict with commit 7e1223b50089 ("iwlwifi: mvm: new
> Alive / error table API") that Stephen found and he resolved it with
> cd98c1ef4ec1a4d08e920060b70e47a5a4e69377."
> 
> That is, if that commit sha1 still exists.

I'll be sure to explain this to Linus.
