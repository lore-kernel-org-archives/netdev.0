From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] Disintegrate UAPI for net
Date: Tue, 09 Oct 2012 13:17:04 -0400 (EDT)
Message-ID: <20121009.131704.983863129128480075.davem@davemloft.net>
References: <30725.1349789433@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <30725.1349789433@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 09 Oct 2012 14:30:33 +0100

> Can you merge the following branch into the net tree please.
> 
> This is to complete part of the Userspace API (UAPI) disintegration for which
> the preparatory patches were pulled recently.  After these patches, userspace
> headers will be segregated into:
> 
> 	include/uapi/linux/.../foo.h
> 
> for the userspace interface stuff, and:
> 
> 	include/linux/.../foo.h
> 
> for the strictly kernel internal stuff.
> 
> ---
> The following changes since commit 9e2d8656f5e8aa214e66b462680cf86b210b74a8:
> 
>   Merge branch 'akpm' (Andrew's patch-bomb) (2012-10-09 16:23:15 +0900)
> 
> are available in the git repository at:
> 
> 
>   git://git.infradead.org/users/dhowells/linux-headers.git tags/disintegrate-net-20121009

Ok I pulled this and the ISDN one too.

Thanks.
