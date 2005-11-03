From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Thu, 3 Nov 2005 06:02:22 +0100
Message-ID: <20051103050222.GA19095@alpha.home.local>
References: <20051102092959.GA15515@alpha.home.local> <OF9D4BE592.A4BBC034-ON882570AD.00608386-882570AD.006143BA@us.ibm.com> <20051102205926.GB5078@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Yan Zheng <yzcorp@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750726AbVKCFOJ@vger.kernel.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Content-Disposition: inline
In-Reply-To: <20051102205926.GB5078@logos.cnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 02, 2005 at 06:59:26PM -0200, Marcelo Tosatti wrote:
> On Wed, Nov 02, 2005 at 09:42:37AM -0800, David Stevens wrote:
> > Willy Tarreau <willy@w.ods.org> wrote on 11/02/2005 01:29:59 AM:
> >  
> > > Marcelo, David, does this backport seem appropriate for 2.4.32 ? I 
> > verified
> > > that it compiles, nothing more.
> > 
> >         Yes.
> > 
> > > If it's OK, I've noticed another patch that
> > > Yan posted today and which might be of interest before a very solid 
> > release.
> > 
> >         I think they should be reviewed first. :-)
> 
> Alright, then let it be tested in v2.6 first. Willy, can you queue for
> 2.4.33-pre ?

OK.

Willy
