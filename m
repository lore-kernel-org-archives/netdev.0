From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] conntrack: restart gc immediately if GC_MAX_EVICTS
 is reached
Date: Wed, 19 Oct 2016 18:14:12 +0200
Message-ID: <20161019161412.GA6542@salvia>
References: <34d607cc-5556-89c7-673d-be8cb0a4758a@6wind.com>
 <1476794252-12398-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476794252-12398-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2016 at 02:37:32PM +0200, Nicolas Dichtel wrote:
> When the maximum evictions number is reached, do not wait 5 seconds before
> the next run.

Applied, thanks Nicolas.
