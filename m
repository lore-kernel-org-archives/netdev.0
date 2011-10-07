From: David Miller <davem@davemloft.net>
Subject: Re: moving GIT back to kernel.org...
Date: Fri, 07 Oct 2011 18:46:57 -0400 (EDT)
Message-ID: <20111007.184657.1471438956485710175.davem@davemloft.net>
References: <20111007.145703.842130763413648388.davem@davemloft.net>
	<20111007.155902.916470368193047875.davem@davemloft.net>
	<20111008094212.e3342930c1833f73ef602a3e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	netfilter-devel@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-ide@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20111008094212.e3342930c1833f73ef602a3e@canb.auug.org.au>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Sat, 8 Oct 2011 09:42:12 +1100

> On Fri, 07 Oct 2011 15:59:02 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc.git
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide.git
> 
> You used to have sparc-next and ide-next (and the above used to be your
> "current release fixes" trees) ...

I've made a dummy sparc-next tree for you to pull from, thanks:

git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-next.git

As for ide, I only plan to accept real bug fixes for that subsystem
so I'll avoid creating an ide-next tree for now.
