From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v2] netns: avoid directory traversal (was: ip netns: Make
 sure netns name is sane)
Date: Thu, 20 Jul 2017 09:44:10 +0200
Message-ID: <20170720074410.GG16375@orbyte.nwl.cc>
References: <20170718171230.084c804e@xeon-e3>
 <20170719223632.4124-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Matteo Croce <mcroce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33561 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933883AbdGTHoL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Jul 2017 03:44:11 -0400
Content-Disposition: inline
In-Reply-To: <20170719223632.4124-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matteo,

I don't think git-am understands the subject change semantics you use
here, so please drop the '(was: ...)' part from it.

On Thu, Jul 20, 2017 at 12:36:32AM +0200, Matteo Croce wrote:
> v2: reword commit message

In my opinion, this belongs to patch meta info (below the three-dashes
line), not the commit message.

Please put the maintainer in Cc when submitting patches. It helps them
to keep track of it. This counts for all upstream projects, not just
iproute2.

Thanks, Phil
