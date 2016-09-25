From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next v3 0/7] Compact netfilter hooks list
Date: Sun, 25 Sep 2016 13:30:01 +0200
Message-ID: <20160925113001.GA8291@salvia>
References: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 21, 2016 at 11:35:00AM -0400, Aaron Conole wrote:
> This series makes a simple change to shrink the netfilter hook list
> from a double linked list, to a singly linked list.  Since the hooks
> are always traversed in-order, there is no need to maintain a previous
> pointer.
> 
> This was jointly developed by Florian Westphal.

Series applied, thanks.
