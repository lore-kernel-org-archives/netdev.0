From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: QRTR merge conflict resolution (was: Re: linux-next: build failure after merge of the net-next tree)
Date: Sat, 14 May 2016 21:47:11 +0200
Message-ID: <3145757.u11669EZop@wuerfel>
References: <20160510112905.5bffcad8@canb.auug.org.au> <20160513221909.GC1256@tuxbot> <CAPBZ5Qfa+b1LLgqpxfKGysY5jXVrzmBzhga=ZYtpdDAKC9hnTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	linux-next@vger.kernel.org, Olof Johansson <olof@lixom.net>
To: Andy Gross <andy.gross@linaro.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAPBZ5Qfa+b1LLgqpxfKGysY5jXVrzmBzhga=ZYtpdDAKC9hnTQ@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 13 May 2016 17:47:17 Andy Gross wrote:
> On 13 May 2016 at 17:19, Bjorn Andersson <bjorn.andersson@linaro.org> wrote:
> > On Fri 13 May 14:01 PDT 2016, Arnd Bergmann wrote:
> >
> >> On Tuesday 10 May 2016 11:39:34 Bjorn Andersson wrote:
> > [..]
> >> > I assume we could have the QRTR go through Andy and arm-soc, with
> >> > David's approval and this fix squashed in. But we're running rather late
> >> > in this cycle, perhaps we should just back the QRTR patches out and I
> >> > can respin and resend them after the merge window (for v4.8 instead)?
> >>
> >> I'd suggest you do a merge of next-next with the qcom/soc-2 branch that
> >> we have in arm-soc and resolve the conflict in the merge, then send
> >> a pull request with the merge to davem.
> >>
> >
> > Hi David,
> >
> > In case you missed this thread, linux-next highlighted an upcoming merge
> > conflict between the net-next and one of the branches included in the
> > arm-soc trees.
> >
> > I have prepared the merge of net-next and the conflicting tag from the
> > Qualcomm SOC, please include this in your pull towards Linus to avoid
> > the merge conflict.
> >
> > Regards,
> > Bjorn
> >
> > The following changes since commit ed7cbbce544856b20e5811de373cf92e92499771:
> >
> >   udp: Resolve NULL pointer dereference over flow-based vxlan device (2016-05-13 01:56:14 -0400)
> 
> 
> OK. The contents look good to me.
> 
> Acked-by: Andy Gross <andy.gross@linaro.org>

Acked-by: Arnd Bergmann <arnd@arndb.de>
