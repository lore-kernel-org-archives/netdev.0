From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: limit unix_tot_inflight
Date: Fri, 26 Nov 2010 18:27:14 -0800 (PST)
Message-ID: <20101126.182714.226785459.davem@davemloft.net>
References: <1290553918.2866.80.camel@edumazet-laptop>
	<1290590335.3464.24.camel@edumazet-laptop>
	<20101126085000.GA4532@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, vegard.nossum@gmail.com,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	eugene@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: mhocko@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101126085000.GA4532@tiehlicka.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Hocko <mhocko@suse.cz>
Date: Fri, 26 Nov 2010 09:50:00 +0100

> Shouldn't this go to stable?
> AFAICS 2.6.32 contains the same code (the patch applies). 
> I haven't tried to reproduce the issue yet.

I'll submit it to all the stable branches after this patch (and the
other AF_UNIX fixes recently proposed) have sat in Linus's tree for at
least half a week or so.
