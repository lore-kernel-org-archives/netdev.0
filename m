From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 0/6] net: use core MTU range checking everywhere
Date: Wed, 19 Oct 2016 15:29:05 -0400
Message-ID: <20161019192905.GI18569@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161019.151005.240728702055002369.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161019.151005.240728702055002369.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2016 at 03:10:05PM -0400, David Miller wrote:
> From: Jarod Wilson <jarod@redhat.com>
> Date: Tue, 18 Oct 2016 22:33:27 -0400
> 
> > This stack of patches should get absolutely everything in the kernel
> > converted from doing their own MTU range checking to the core MTU range
> > checking.
> 
> I'm expecting a respin of this series.

Absolutely. Will address all review comments, and have some additional
patches to add to the series to hopefully have absolutely everything
functional, asap.

-- 
Jarod Wilson
jarod@redhat.com
