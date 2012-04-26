From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/2] ipvs: netns avoid crash at netns init
Date: Thu, 26 Apr 2012 11:30:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204261126340.1879@ja.ssi.bg>
References: <1335426335-5093-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: horms@verge.net.au, wensong@linux-vs.org,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335426335-5093-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 26 Apr 2012, Hans Schillstrom wrote:

> Two simple patches that avoid crashes for no memory at netns init.
> 
> - Check return value of protocoll init.
> - Null check of net-ipvs in shedulers.
> 
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

	Both patches look ok

Acked-by: Julian Anastasov <ja@ssi.bg>

