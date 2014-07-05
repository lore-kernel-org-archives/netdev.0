From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Sat, 05 Jul 2014 11:31:39 -0700
Message-ID: <1404585099.6384.53.camel@joe-AO725>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
	 <20140702.182807.1245632778216212860.davem@davemloft.net>
	 <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
	 <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
	 <1404356734.14741.18.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
	 <1404364565.14741.26.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
	 <1404368746.14741.36.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org>
	 <1404576420.6384.41.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051833400.15455@eddie.linux-mips.org>
	 <1404583739.6384.51.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051917480.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1407051917480.15455@eddie.linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-07-05 at 19:20 +0100, Maciej W. Rozycki wrote:
> On Sat, 5 Jul 2014, Joe Perches wrote:
> > I don't think %#p is valid so it
> > shouldn't have been set by #.
> 
>  Huh?  As recently as last Wednesday you pointed me at the specific commit 
> from Grant that made it valid (GCC format complaints aside).

Those gcc complaints are precisely the thing
that makes it invalid.

I believe you're tilting at windmills.

Hey, it works sometimes.  Knock yourself out.
