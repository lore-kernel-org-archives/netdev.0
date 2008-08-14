From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dccp: change L/R must have at least one byte in the
 dccpsf_val field
Date: Wed, 13 Aug 2008 18:12:26 -0700 (PDT)
Message-ID: <20080813.181226.115891097.davem@davemloft.net>
References: <20080813125532.GD12888@ghostprotocols.net>
	<28fa9c5e0808131808x40a2e902jeccf962dd86cfb32@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: eugeneteo@kernel.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43503
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751917AbYHNBMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 21:12:25 -0400
In-Reply-To: <28fa9c5e0808131808x40a2e902jeccf962dd86cfb32@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eugene Teo" <eugeneteo@kernel.sg>
Date: Thu, 14 Aug 2008 09:08:56 +0800

> On Wed, Aug 13, 2008 at 8:55 PM, Arnaldo Carvalho de Melo
> <acme@redhat.com> wrote:
> > Hi David, Gerrit,
> >
> >        Please consider applying.
> >
> > - Arnaldo
> >
> > dccp: change L/R must have at least one byte in the dccpsf_val field
> >
> > Thanks to Eugene Teo for reporting this problem.
> >
> > Signed-off-by: Eugene Teo <eugenete@kernel.sg>
> 
> Should be eugeneteo@ instead of eugenete. Thanks.

I'll fix this up for the -stable submission, this version
is already in my net-2.6 tree and on the way to Linus.

Thanks.

