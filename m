From: Christoph Hellwig <hch@lst.de>
Subject: Re: Bug#267342: kernel-image-2.6.8-1-686-smp: /proc/sys/net/ipv4/tcp_default_win_scale offers a fix
Date: Wed, 25 Aug 2004 16:48:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825144855.GB10396@lst.de>
References: <20040822024009.EA88B9E0@maus.private.neotoma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kristine Diana Daniels <kddaniel@private.neotoma.org>,
        267342@bugs.debian.org
Content-Disposition: inline
In-Reply-To: <20040822024009.EA88B9E0@maus.private.neotoma.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 21, 2004 at 10:40:09PM -0400, Kristine Diana Daniels wrote:
> Package: kernel-image-2.6.8-1-686-smp
> Version: 2.6.8-1
> Followup-For: Bug #267342
> 
> 
> putting values less than or equal to 6 in 
> /proc/sys/net/ipv4/tcp_default_win_scale
> resolves the nntp issue.
> putting values less than or equial to 3 in
> /proc/sys/net/ipv4/tcp_default_win_scale
> resolves the ssh from openbsd issue.
> 
> This was tested from a 2.6.8-1-k7 system

Urgg, I should have read this earlies.  Seems like OpenBSD is indeed
buggy.
