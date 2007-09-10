From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Lksctp-developers] [-mm patch] net/sctp/socket.c: make 3 variables static
Date: Mon, 10 Sep 2007 10:05:07 -0400
Message-ID: <20070910140507.GD14606@hmsendeavour.rdu.redhat.com>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070909202554.GY3563@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759968AbXIJOHy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070909202554.GY3563@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 09, 2007 at 10:25:54PM +0200, Adrian Bunk wrote:
> On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
> >...
> > Changes since 2.6.23-rc3-mm1:
> >...
> >  git-net.patch
> >...
> >  git trees
> >...
> 
> This patch makes the following needlessly globalvariables static:
> - sctp_memory_pressure
> - sctp_memory_allocated
> - sctp_sockets_allocated
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
Looks fine to me
Acked-by: Neil Horman <nhorman@tuxdriver.com>

Neil

-- 
/***************************************************
 *Neil Horman
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
