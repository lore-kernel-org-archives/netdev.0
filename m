From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping transmit
 ring on timeout
Date: Wed, 30 Apr 2014 14:22:02 +0800
Message-ID: <20140430062200.GB16727@dragon>
References: <1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
 <CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
 <20140429141527.GZ26756@n2100.arm.linux.org.uk>
 <CAHrpEqTc6=yS4ApLO7AbZyVq26kGxq+WBcyFjgjbiPySq7055Q@mail.gmail.com>
 <20140429143243.GA26756@n2100.arm.linux.org.uk>
 <CAHrpEqQL7LviXA4_NLNwSBoW84W_vbnzWkc9At5QBqUkqu63yw@mail.gmail.com>
 <20140429150403.GC26756@n2100.arm.linux.org.uk>
 <CAHrpEqSw3iwJj1nHuCJ7LcoL2EUxYqMb-eA1QZN0_WvR-Y_mWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Frank Li <Frank.Li@freescale.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "B38611@freescale.com" <B38611@freescale.com>,
 David Laight <David.Laight@aculab.com>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <CAHrpEqSw3iwJj1nHuCJ7LcoL2EUxYqMb-eA1QZN0_WvR-Y_mWA@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2014 at 10:11:18AM -0500, Frank Li wrote:
> On Tue, Apr 29, 2014 at 10:04 AM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > I'd just like to see what you're doing.  Note that your submission also
> > didn't get through the linux-arm-kernel list either, so I didn't get it
> > via that path either.
> 
> We have not sent out to public mail list yet.
> But there are really big change.
> We need support 3 ring queues for tx and rx.

Frank,

I guess Russell was saying that these 7 patches did not reach
linux-arm-kernel list for some reason.

Shawn
