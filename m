From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter: Use list_{next/prev}_entry instead of
 list_entry
Date: Fri, 7 Apr 2017 17:31:22 +0200
Message-ID: <20170407153122.GC1466@salvia>
References: <20170329054540.GA15593@singhal-Inspiron-5558>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: simran singhal <singhalsimran0@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170329054540.GA15593@singhal-Inspiron-5558>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 11:15:40AM +0530, simran singhal wrote:
> This patch replace list_entry with list_prev_entry as it makes the
> code more clear to read.

Also applied, thanks.
