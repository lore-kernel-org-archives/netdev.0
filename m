From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec doesn't route TCP with 4.11 kernel
Date: Fri, 19 May 2017 12:03:42 +0200
Message-ID: <20170519100342.GD22049@secunet.com>
References: <CADJev78Cs0VBdagtfU-71pv3HHC5Vq41UXQee856aVbUqEqAYg@mail.gmail.com>
 <CAM_iQpWT5tF5+LpoTP98JNJ=440jEkxHFkn8=jtAsZgondN49A@mail.gmail.com>
 <20170427084238.GX2649@secunet.com>
 <CADJev7_=YEHmijGweqZvdATMQVuzwywEbBKweYvPurJfTEQRjQ@mail.gmail.com>
 <20170428071337.GG2649@secunet.com>
 <CADJev7_Tc0aRsPs0Q7Wijd-YBM39ZshitJpSo2yEqPVwag2X_Q@mail.gmail.com>
 <20170503081421.GL2649@secunet.com>
 <CADJev78iruiwBz6nSPgnaG0FPXruJ2Qv9qHpRxg1sm=mHG3RYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Don Bowman <db@donbowman.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CADJev78iruiwBz6nSPgnaG0FPXruJ2Qv9qHpRxg1sm=mHG3RYw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 03:05:40PM -0400, Don Bowman wrote:
> On 3 May 2017 at 04:14, Steffen Klassert <steffen.klassert@secunet.com> wrote:
> > On Sat, Apr 29, 2017 at 08:39:34PM -0400, Don Bowman wrote:
> >> On 28 April 2017 at 03:13, Steffen Klassert
> >> <steffen.klassert@secunet.com> wrote:
> >> > On Thu, Apr 27, 2017 at 06:13:38PM -0400, Don Bowman wrote:
> >> >> On 27 April 2017 at 04:42, Steffen Klassert <steffen.klassert@secunet.com>
> >> >> wrote:
> >> >> > On Wed, Apr 26, 2017 at 10:01:34PM -0700, Cong Wang wrote:
> >> >> >> (Cc'ing netdev and IPSec maintainers)
> >> >> >>
> >> >> >> On Tue, Apr 25, 2017 at 6:08 PM, Don Bowman <db@donbowman.ca> wrote:
> >> >>
> >>
> >> <snip>
> >>
> >> confirmed, with this patch in place that the tcp functions properly.
> >
> > Thanks for testing!
> >
> > I'll make sure to get this fix into the mainline soon.
> 
> Thanks. Let me know if there is any more assistance I can provide.
> I've been running the patch for 2 weeks now on 3 machines.

Thanks for testing!
I plan to push it upstream at the beginning of te next week.
