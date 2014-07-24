From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: filter: split eBPF interpreter out
 of core networking
Date: Wed, 23 Jul 2014 21:08:31 -0700 (PDT)
Message-ID: <20140723.210831.253096883800350687.davem@davemloft.net>
References: <1406095319-3627-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406095319-3627-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 22 Jul 2014 23:01:57 -0700

> I believe my recent set of RFC/patches [1] provided good visibility on where
> I would like to take eBPF subsystem. These two trivial patches is a first step
> in that direction:
> patch 1 - mechanical split of eBPF interpreter out of filter.c
> patch 2 - nominate myself as a maintainer for eBPF core pieces
> In the foreseeable future eBPF patches will be going through net-next,
> so put netdev as a primary mailing list
> 
> [1] git://git.kernel.org/pub/scm/linux/kernel/git/ast/bpf master

Series applied to net-next.
