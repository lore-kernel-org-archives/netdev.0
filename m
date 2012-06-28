From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] net: nfc: fix panic in accept()
Date: Thu, 28 Jun 2012 14:56:12 +0200
Message-ID: <20120628125612.GG4846@sortiz-mobl>
References: <1339425693.6001.2268.camel@edumazet-glaptop>
 <20120611145700.GY22557@sortiz-mobl>
 <1339426778.6001.2312.camel@edumazet-glaptop>
 <20120611152007.GZ22557@sortiz-mobl>
 <1339433810.4999.65.camel@lappy>
 <20120611172545.GA1776@redhat.com>
 <CA+1xoqcwr-5dzHvqkt9x0-xj9EFAywVfva=asbHXvX-LSBWqdA@mail.gmail.com>
 <1340639612.10893.84.camel@edumazet-glaptop>
 <20120625171532.GB16275@sortiz-mobl>
 <CA+1xoqfy21wOh2myV0D6iBDqoZ3YmkwNZwKBVXLU75zePOGi4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Jones <davej@redhat.com>,
	David Miller <davem@davemloft.net>,
	lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+1xoqfy21wOh2myV0D6iBDqoZ3YmkwNZwKBVXLU75zePOGi4w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

On Thu, Jun 28, 2012 at 02:11:38PM +0200, Sasha Levin wrote:
> Hi Samuel,
> 
> On Mon, Jun 25, 2012 at 7:15 PM, Samuel Ortiz <sameo@linux.intel.com> wrote:
> > Hi Eric,
> >
> > On Mon, Jun 25, 2012 at 05:53:32PM +0200, Eric Dumazet wrote:
> >> From: Eric Dumazet <edumazet@google.com>
> >>
> >> Sasha Levin reported following panic :
> > I applied a similar patch, more consistent with the rest of the NFC socket
> > code, still with you as the author. See here:
> >
> > http://git.kernel.org/?p=linux/kernel/git/sameo/nfc-3.0.git;a=commit;h=631c301f20558525a641fadffc0126affd3dc4a4
> 
> Could this tree be included in -next please?
No, wireless-next is already included in -next. The above patch is making its
way upstream, it's in the wireless.git tree and should hit davem's net tree
soon.

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
