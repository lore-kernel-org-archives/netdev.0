From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Sun, 8 Jun 2003 16:49:26 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030608234926.GA9453@netnation.com>
References: <87wuge59w2.fsf@deneb.enyo.de> <20030526.233211.54217447.davem@redhat.com> <87he70re62.fsf@deneb.enyo.de> <20030608.050500.28795668.davem@redhat.com> <874r30r9z2.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Florian Weimer <fw@deneb.enyo.de>
Content-Disposition: inline
In-Reply-To: <874r30r9z2.fsf@deneb.enyo.de>
List-Id: netdev.vger.kernel.org

On Sun, Jun 08, 2003 at 03:10:25PM +0200, Florian Weimer wrote:

> Further parameters which could be tweaked is the kind of adjacency
> information (where to store the L2 information, whether to include the
> prefix length in the adjacency record etc.).

What is the problem with the current approach?  Does the overhead come
from having to iterate through the hashes for each prefix?

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][   NetNation Communications Inc.  ]
[  Opinions expressed are not necessarily those of my employer. ]
