From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [ethtool PATCH v2 4/4] ethtool: Enhancing link mode bits to
 support 25G/50G/100G
Date: Tue, 2 Aug 2016 15:49:57 -0400
Message-ID: <20160802194957.GC24663@tuxdriver.com>
References: <1466970307-2411-5-git-send-email-vidya@cumulusnetworks.com>
 <CO2PR11MB00889D2C55C1E4C86D831C59970C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKWE-XqpkNprFcQj7wZEthmTTtDuU7657kjFP37EvrgCChncHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>,
	"bwh@kernel.org" <bwh@kernel.org>,
	David Miller <davem@davemloft.net>,
	"decot@googlers.com" <decot@googlers.com>,
	"bkenward@solarflare.com" <bkenward@solarflare.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>,
	"galp@mellanox.com" <galp@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"dustin@cumulusnetworks.com" <dustin@cumulusnetworks.com>
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41439 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbcHBVxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 17:53:41 -0400
Content-Disposition: inline
In-Reply-To: <CAKWE-XqpkNprFcQj7wZEthmTTtDuU7657kjFP37EvrgCChncHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Are these revised patches still on their way?

John

On Sun, Jul 24, 2016 at 01:57:14AM -0700, Vidya Sagar Ravipati wrote:
> Yuval,
>     I will try to resubmit the patches this week with updated comments
> 
> Thanks
> Vidya Sagar
> 
> On Sat, Jul 23, 2016 at 10:57 PM, Yuval Mintz <Yuval.Mintz@qlogic.com>
> wrote:
> 
> > > Enhancing link mode bits to support 25G/50G/100G for supported and
> > > advertised speed mode bits
> > >
> > > Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> > > ---
> > >  ethtool.c | 27 +++++++++++++++++++++++++++
> > >  1 file changed, 27 insertions(+)
> >
> > Hi Vidya,
> >
> > Are you re-trying your series one anytime soon?
> >
> > If not, can we simply push this [and ethtool-copy.h], as those are needed
> > for querying/setting the recently added new speeds.
> >
> >

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
