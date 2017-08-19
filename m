From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xtables: use audit_log()
Date: Sat, 19 Aug 2017 13:25:44 +0200
Message-ID: <20170819112544.GB4761@salvia>
References: <5f901760510d0dc6e6e971d4136c8d2d4e0a13fd.1502103408.git.geliangtang@gmail.com>
 <c091f8c337fe4316ffcfb121da8b24b6633fa679.1502099123.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c091f8c337fe4316ffcfb121da8b24b6633fa679.1502099123.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2017 at 09:44:26PM +0800, Geliang Tang wrote:
> Use audit_log() instead of open-coding it.

As said, collapsed into 'netfilter: ebtables: use audit_log()', just
for the record.
