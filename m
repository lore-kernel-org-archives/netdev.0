From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 0/2] ravb: Support 1Gbps on R-Car H3 ES1.1+ and
 R-Car M3-W
Date: Fri, 27 Jan 2017 17:34:20 +0100
Message-ID: <20170127163417.GA7336@verge.net.au>
References: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
 <CAMuHMdUdHVcFpQyqtngps__Z99vWBYbs1vVvVSLvKBWSEkOrgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Magnus Damm <magnus.damm@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdUdHVcFpQyqtngps__Z99vWBYbs1vVvVSLvKBWSEkOrgw@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2017 at 01:16:43PM +0100, Geert Uytterhoeven wrote:
> Hi Simon,
> 
> On Fri, Jan 27, 2017 at 12:04 PM, Simon Horman
> <horms+renesas@verge.net.au> wrote:
> > The path from Mizuguchi-san is to address timing problems observed with
> > gigabit transfers. I would like it considered although my own testing on
> > M3-W did not show any timing problems.
> 
> Is there any relation with the *-skew-ps properties in the DTS in the BSP?

Yes, I believe they are also intended to address timeouts.
I plan to post them too.
