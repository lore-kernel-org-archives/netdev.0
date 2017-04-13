From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] nf_conntrack: remove double assignment
Date: Fri, 14 Apr 2017 01:27:37 +0200
Message-ID: <20170413232737.GB7721@salvia>
References: <20170412203254.14625-1-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170412203254.14625-1-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 04:32:54PM -0400, Aaron Conole wrote:
> The protonet pointer will unconditionally be rewritten, so just do the
> needed assignment first.

Also applied, thanks.
