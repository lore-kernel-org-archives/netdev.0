From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH netfilter-next] xt_osf: Use continue to reduce indentation
Date: Tue, 23 Dec 2014 14:17:47 +0100
Message-ID: <20141223131747.GA5369@salvia>
References: <1418761033.14140.5.camel@perches.com>
 <8632531418806285@web23h.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8632531418806285@web23h.yandex.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 17, 2014 at 11:51:25AM +0300, Evgeniy Polyakov wrote:
> Hi everyone
> 
> 16.12.2014, 23:17, "Joe Perches" <joe@perches.com>:
> > Invert logic in test to use continue.
> >
> > This routine already uses continue, use it a bit more to
> > minimize > 80 column long lines and unnecessary indentation.
> >
> > No change in compiled object file.
> 
> Looks good. Thank you.
> Which tree should this patch go through? Please pull it in.
> 
> Acked-by: Evgeniy Polyakov <zbr@ioremap.net>

Applied to nf-next, thanks.
