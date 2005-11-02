From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Wed, 2 Nov 2005 19:46:06 -0200
Message-ID: <39e6f6c70511021346g43fcba88y77c63fdff8cf9bb6@mail.gmail.com>
References: <20051102092959.GA15515@alpha.home.local>
	 <OF9D4BE592.A4BBC034-ON882570AD.00608386-882570AD.006143BA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Willy Tarreau <willy@w.ods.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
	netdev@vger.kernel.org, Yan Zheng <yzcorp@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965282AbVKBVqJ@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF9D4BE592.A4BBC034-ON882570AD.00608386-882570AD.006143BA@us.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/2/05, David Stevens <dlstevens@us.ibm.com> wrote:
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

Sure thing David, and thanks for your much appreciated review of patches for
the area.

- Arnaldo
