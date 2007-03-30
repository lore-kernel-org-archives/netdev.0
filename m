From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-MM GIT PULL] e1000: fixes, API rewrite, cleanups
Date: Thu, 29 Mar 2007 17:13:43 -0700
Message-ID: <20070329171343.69abfc13.akpm@linux-foundation.org>
References: <20070329225815.C977F40951@ahkok-mobl.jf.intel.com>
	<20070329165739.04003147.akpm@linux-foundation.org>
	<460C53CC.3010207@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, john.ronciak@intel.com,
	arjan@linux.intel.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43895 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934379AbXC3ANt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 20:13:49 -0400
In-Reply-To: <460C53CC.3010207@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2007 17:03:24 -0700
"Kok, Auke" <auke-jan.h.kok@intel.com> wrote:

> > The current davem diff is 2.2MB, touching 852 files.  Nobody breathe...
>

Just for giggles:

git-net:          852 files changed, 10326 insertions(+), 27095 deletions(-)
git-netdev-all:   146 files changed, 39390 insertions(+), 3099 deletions(-)
git-wireless:     201 files changed, 85602 insertions(+), 620 deletions(-)
git-e1000:         32 files changed, 20117 insertions(+), 13478 deletions(-)
git-ipwireless_cs: 11 files changed, 3619 insertions(+)

for a total of nearly 8MB of networking diff.  They flower in the
Spring, obviously.

> 
> it looks about right. I'll try to verify tomorrow that it is OK.

I'll get what I have now compiling and booting and then I'll shove
another -mm out the door.  Hopefully this evening..

