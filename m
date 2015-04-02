From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 01/14] netfilter: bridge: really save
 frag_max_size between PRE and POST_ROUTING
Date: Thu, 2 Apr 2015 10:53:22 +0200
Message-ID: <20150402085322.GA10375@salvia>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
 <1427920600-20366-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427920600-20366-2-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 01, 2015 at 10:36:27PM +0200, Florian Westphal wrote:
> We also need to save/store in forward, else br_parse_ip_options call
> will zero frag_max_size as well.

I have only applied this fix to nf-next. Thanks.
