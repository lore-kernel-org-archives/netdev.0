From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [patch]: ipv6 tunnel for MIPv6
Date: Thu, 5 Jun 2003 11:36:47 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306051120570.30092-100000@rhea.tcs.hut.fi>
References: <Pine.GSO.4.44.0306041941480.8428-100000@morphine.tml.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Cc: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>,
   <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>, <ajtuomin@morphine.tml.hut.fi>,
   Venkata Jagana <jagana@us.ibm.com>, <kumarkr@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Petander <lpetande@morphine.tml.hut.fi>
In-Reply-To: <Pine.GSO.4.44.0306041941480.8428-100000@morphine.tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Jun 2003, Henrik Petander wrote:

> Hello Yoshifuji,
>
> On Thu, 5 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> > In article <3EDE0286.4000304@tml.hut.fi> (at Wed, 04 Jun 2003 17:30:30 +0300), Henrik Petander <lpetande@tml.hut.fi> says:
> >
> > > 2. Source address based routing
> >
> > I'm not sure why you need this (and tunnel) for MIP...
> > Would you clearify for me?
> > (IMHO, I believe we don't need this change if we use XFRM engine.)
>
> As far as I remember there  are three main reasons for this: (Ville
> correct me if  forgot something)

I think you've got all the main reasons. I'll get back to this issue
if I suddenly remember something you forgot. :)


-Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
