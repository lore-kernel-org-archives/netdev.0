From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Wed, 2 Nov 2005 18:59:26 -0200
Message-ID: <20051102205926.GB5078@logos.cnet>
References: <20051102092959.GA15515@alpha.home.local> <OF9D4BE592.A4BBC034-ON882570AD.00608386-882570AD.006143BA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <willy@w.ods.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Yan Zheng <yzcorp@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030270AbVKCB4v@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF9D4BE592.A4BBC034-ON882570AD.00608386-882570AD.006143BA@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 02, 2005 at 09:42:37AM -0800, David Stevens wrote:
> Willy Tarreau <willy@w.ods.org> wrote on 11/02/2005 01:29:59 AM:
>  
> > Marcelo, David, does this backport seem appropriate for 2.4.32 ? I 
> verified
> > that it compiles, nothing more.
> 
>         Yes.
> 
> > If it's OK, I've noticed another patch that
> > Yan posted today and which might be of interest before a very solid 
> release.
> 
>         I think they should be reviewed first. :-)

Alright, then let it be tested in v2.6 first. Willy, can you queue for
2.4.33-pre ?
