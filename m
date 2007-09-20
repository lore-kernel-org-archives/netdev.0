From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: net-2.6.24 plans
Date: Thu, 20 Sep 2007 15:50:11 -0400
Message-ID: <20070920195011.GL6748@tuxdriver.com>
References: <20070916.202258.03371690.davem@davemloft.net> <20070917.141826.70218261.davem@davemloft.net> <20070917144037.100b3fc1.akpm@linux-foundation.org> <20070917231830.GG9282@tuxdriver.com> <20070917164929.b53ac118.akpm@linux-foundation.org> <20070918032328.GB3875@tuxdriver.com> <20070919012752.GA3717@tuxdriver.com> <20070919210700.GF5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4748 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800AbXITUIO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 16:08:14 -0400
Content-Disposition: inline
In-Reply-To: <20070919210700.GF5483@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 05:07:00PM -0400, John W. Linville wrote:
> On Tue, Sep 18, 2007 at 09:27:52PM -0400, John W. Linville wrote:
> > On Mon, Sep 17, 2007 at 11:23:28PM -0400, John W. Linville wrote:
> > > On Mon, Sep 17, 2007 at 04:49:29PM -0700, Andrew Morton wrote:
> > > > On Mon, 17 Sep 2007 19:18:30 -0400
> > > > "John W. Linville" <linville@tuxdriver.com> wrote:
> > > > 
> > > > > P.S.  Andrew, I'll send you a link to a new git-wireless.patch --
> > > > > I'm sure you don't want a complicated git invocation...  Until then,
> > > > > I don't think you should try pulling wireless-dev...
> > 
> > > Anyway, I do have prepared an omnibus patch for you:
> > 
> > Since Dave merged the drivers I sent him, the new omnibus patch you
> > want is this:

> > The good news is that it is 1/4 the size of its predecessor!
> 
> And the latest incarnation:

> And is even smaller...down an additional 30%, or almost 1/6th of the
> original! :-)

	http://www.kernel.org/pub/linux/kernel/people/linville/git-wireless-2007-09-20.patch

Even smaller, about 650k -- 80+% reduction in size, hooray!

John
-- 
John W. Linville
linville@tuxdriver.com
