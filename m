From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Fri, 11 Aug 2017 22:07:15 +0200
Message-ID: <20170811200715.6yxjqwslf2pcu2wn@torres.zugschlus.de>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
 <1500905950.2458.6.camel@redhat.com>
 <20170728062644.bp7agcf6bh7g6yfw@torres.zugschlus.de>
 <1501229277.2597.1.camel@redhat.com>
 <20170728121434.vld76q7kohzpmtk2@torres.zugschlus.de>
 <20170811143453.6vrf2us2jev2ys3d@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:51116 "EHLO
        torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbdHKUHR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:07:17 -0400
Content-Disposition: inline
In-Reply-To: <20170811143453.6vrf2us2jev2ys3d@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 04:34:53PM +0200, Marc Haber wrote:
> On Fri, Jul 28, 2017 at 02:14:34PM +0200, Marc Haber wrote:
> > I can confirm that these two changes make a system in bad state work
> > again immediately. Will try the patch on 4.12.4 later today.
> 
> After upgrading my test systems to 4.12.5, the issue reappeared. This
> shows me that the patch indeed helped (my patched 4.12.4 kernels didn't
> show the bad behavior), and that the patch didn't make its way into
> 4.12.5. The patch applied to 4.12.5, kernels are building.

It seems to be in the freshly released 4.12.6.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
