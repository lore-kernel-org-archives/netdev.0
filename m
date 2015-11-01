From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] BPF updates
Date: Sun, 01 Nov 2015 12:16:51 -0500 (EST)
Message-ID: <20151101.121651.1361940420226820359.davem@davemloft.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, hannes@stressinduktion.org, tgraf@suug.ch,
	viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 29 Oct 2015 14:58:05 +0100

> This set adds support for persistent maps/progs. Please see
> individual patches for further details. A man-page update
> to bpf(2) will be sent later on, also a iproute2 patch for
> support in tc.
> 
> Thanks!
> 
> v1 -> v2:
>   - Reworked most of patch 4 and 5
>   - Rebased to latest net-next

I'm going to let this sit for a little bit of review time since
this facility seems to be generating at least a little bit of
controversy :-)
