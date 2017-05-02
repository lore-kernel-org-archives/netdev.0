From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ctnetlink: Make some parameters integer to
 avoid enum mismatch
Date: Tue, 2 May 2017 11:58:08 +0200
Message-ID: <20170502095808.GA2321@salvia>
References: <20170419183920.21936-1-mka@chromium.org>
 <20170501180730.GV128305@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S . Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>,
        Greg Hackmann <ghackmann@google.com>,
        Michael Davidson <md@google.com>
To: Matthias Kaehlcke <mka@chromium.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170501180730.GV128305@google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 01, 2017 at 11:07:30AM -0700, Matthias Kaehlcke wrote:
> El Wed, Apr 19, 2017 at 11:39:20AM -0700 Matthias Kaehlcke ha dit:
> 
> > Not all parameters passed to ctnetlink_parse_tuple() and
> > ctnetlink_exp_dump_tuple() match the enum type in the signatures of these
> > functions. Since this is intended change the argument type of to be an int
> > value.
> > 
> > Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> > ---
> 
> Ping, any comments on this patch?

I'll take this in the next batch.
