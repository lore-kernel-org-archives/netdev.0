From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 0/8] cgroup: Assign subsystem IDs during compile time
Date: Tue, 11 Sep 2012 14:11:51 -0700
Message-ID: <20120911211151.GC7677@google.com>
References: <1347380774-9546-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38213 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758176Ab2IKVL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 17:11:56 -0400
Content-Disposition: inline
In-Reply-To: <1347380774-9546-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Sep 11, 2012 at 06:26:06PM +0200, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
> 
> Hi,
> 
> In this version I tried to concentrate on the main topic of this
> series, so I removed some of the things which were not really needed
> and I have to admit the result looks much better. So I hope that will
> simplify the review for you.

Other than the few nits I like the whole series and, given that all
the changes are entangled with cgroup core, I would like to route it
through cgroup/for-3.7 if nobody objects.  Daniel, can you please
rebase on top of the following branch when sending out updated
version?

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.7

Li, can you please review these?

Thanks.

-- 
tejun
