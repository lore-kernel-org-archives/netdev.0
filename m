From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: remove MTU limits on a few ether_setup callers
Date: Fri, 21 Oct 2016 17:59:21 +0200
Message-ID: <20161021155921.GS16974@lunn.ch>
References: <20161021032527.12954-1-jarod@redhat.com>
 <ebcdfc7f-5d91-c64f-19f4-99f58614caae@gmail.com>
 <20161021084441.GC16974@lunn.ch>
 <20161021154851.GE11396@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>,
        R Parameswaran <parameswaran.r7@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161021154851.GE11396@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'm all for fine-tuning things to be more correct, but my initial
> approach here was to restore the ranges that were previously there,
> and DSA had no upper or lower bounds checks. I'm not at all familiar
> with DSA either way.

Please just restore the old behaviour.

We can consider changes later.

       Andrew
