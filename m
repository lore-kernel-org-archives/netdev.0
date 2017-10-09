From: Darren Hart <dvhart@infradead.org>
Subject: Re: linux-next: manual merge of the drivers-x86 tree with the
 net-next tree
Date: Mon, 9 Oct 2017 16:18:10 -0700
Message-ID: <20171009231810.GI12321@fury>
References: <20171009175633.dm7hjmgoxusspue5@sirena.co.uk>
 <20171009194301.GP2761@lahna.fi.intel.com>
 <20171009195634.gzxwcqn7xklumqyr@sirena.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mika Westerberg <mika.westerberg@linux.intel.com>,
        Mario Limonciello <mario.limonciello@dell.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Michael Jamet <michael.jamet@intel.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:52954 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754347AbdJIXSR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 19:18:17 -0400
Content-Disposition: inline
In-Reply-To: <20171009195634.gzxwcqn7xklumqyr@sirena.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 09, 2017 at 08:56:34PM +0100, Mark Brown wrote:
> On Mon, Oct 09, 2017 at 10:43:01PM +0300, Mika Westerberg wrote:
> 
> > If possible, I would rather move this chapter to be before "Networking
> > over Thunderbolt cable". Reason is that it then follows NVM flashing
> > chapter which is typically where you need to force power in the first
> > place.
> 

Agreed.

> I guess that's something best sorted out either in the relevant trees or
> during the merge window?

I'm not sure how we would deal with it in the trees. Best to note this during
the merge window - whichever goes in second. Test merge will identify the merge
conflict, and we can include a note to Linus on the preference.

-- 
Darren Hart
VMware Open Source Technology Center
