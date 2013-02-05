From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [TRIVIAL PATCH V2] Doc: percpu_counter doc code for better
 readability
Date: Tue, 5 Feb 2013 11:54:39 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1302051154280.2260@pobox.suse.cz>
References: <20130204214952.GJ27963@mtj.dyndns.org> <20130204221356.29548.35746.stgit@dragon> <CAOS58YO1VSsbisxSqzcW6n=a+XwcM4F0uHN40OKB9Ok6DSMW7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	joe@perches.com
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43572 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754552Ab3BEKyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 05:54:50 -0500
In-Reply-To: <CAOS58YO1VSsbisxSqzcW6n=a+XwcM4F0uHN40OKB9Ok6DSMW7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Feb 2013, Tejun Heo wrote:

> > Help people reading the percpu_counter code, to notice the ifdef
> > else statement that seperates CONFIG_SMP.
> >
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > Acked-by: Tejun Heo <tj@kernel.org>
> 
> Jiri, can you please take this?

Absolutely, now applied. Thanks,

-- 
Jiri Kosina
SUSE Labs
