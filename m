From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RESEND net-next V2] IB/ipoib: break linkage to
 neighbouring system
Date: Fri, 27 Jul 2012 07:42:01 +0300
Message-ID: <CAJZOPZJZYN5YfVBRrC0Z3kvDfWcU=S7vCi4UWmzre2+PxUyM=g@mail.gmail.com>
References: <1343150651-12568-1-git-send-email-ogerlitz@mellanox.com>
	<20120724.140015.1545062339709165330.davem@davemloft.net>
	<CAG4TOxNrywFPj_91RzkPikPoWP4hwe+2oninuF7zkrBFo6Q3Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, ogerlitz@mellanox.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com, cl@linux.com,
	shlomop@mellanox.com
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:34851 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab2G0EmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 00:42:02 -0400
Received: by gglu4 with SMTP id u4so2771409ggl.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 21:42:01 -0700 (PDT)
In-Reply-To: <CAG4TOxNrywFPj_91RzkPikPoWP4hwe+2oninuF7zkrBFo6Q3Kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 25, 2012 at 10:52 AM, Roland Dreier <roland@kernel.org> wrote:
> On Tue, Jul 24, 2012 at 2:00 PM, David Miller <davem@davemloft.net> wrote:

>> Looks good, Roland you got this?

> Yes, I'll read it over and pick it up, thanks.

Hi Roland,

Just to make sure, you are picking this for 3.6, correct?

I'd like to make sure that the merge of this patch through the
infiniband tree will not introduce dependancy with the review/merge of
the Ethernet IPoIB driver that runs through netdev. If this patch
lands in 3.6-rcX, Dave will eventually pick it into net-next and we're
ok, if not, things get complicated without any real reason, makes
sense?

Or.
