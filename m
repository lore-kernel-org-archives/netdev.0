From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netfilter: allow hooks to pass error code back up
 the stack
Date: Wed, 17 Nov 2010 10:55:54 -0800 (PST)
Message-ID: <20101117.105554.102552958.davem@davemloft.net>
References: <20101116215238.6727.39248.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	selinux@tycho.nsa.gov, netfilter-devel@vger.kernel.org,
	equinox@diac24.net, eric.dumazet@gmail.com, hzhong@gmail.com,
	jmorris@namei.org, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	paul.moore@hp.com, pekkas@netcore.fi, sds@tycho.nsa.gov,
	yoshfuji@linux-ipv6.org
To: eparis@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101116215238.6727.39248.stgit@paris.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@redhat.com>
Date: Tue, 16 Nov 2010 16:52:38 -0500

> SELinux would like to pass certain fatal errors back up the stack.  This patch
> implements the generic netfilter support for this functionality.
> 
> Based-on-patch-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Eric Paris <eparis@redhat.com>

Applied.
