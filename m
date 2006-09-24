From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: bcm43xx driver unstable behaviour (and linux wireless is junk btw)
Date: Sun, 24 Sep 2006 10:05:01 +0200
Message-ID: <200609241005.02024.mb@bu3sch.de>
References: <1159065798.5924.8.camel@localhost.localdomain>
	<4515FF5D.4080602@gentoo.org>
	<1159078683.5924.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1159078683.5924.16.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 24 September 2006 08:18, Benjamin Herrenschmidt wrote:
> On Sat, 2006-09-23 at 23:45 -0400, Daniel Drake wrote:
> > Benjamin Herrenschmidt wrote:
> > > Oh and I don't care about "it works in dscape stack" sort of crap I regulary get. I want something that
> > > works with upstream kernels. That isn't that much to ask... or is it ?
> > 
> > wpa_supplicant triggers races in softmac relatively easily, which are 
> > hard to fix properly. At least for me, motivation to work on this stuff 
> > is low given the potentially impending merge of devicescape, and every 
> > time I do spend some time investigating I just get even more frustrated 
> > at how difficult WE is to implement *properly* for "non-hardmac" 
> > drivers. We really have a need for a configuration system designed 
> > around 802.11.
> > 
> > I agree, the stuff in mainline should be fixed, but at least personally 
> > I am finding it harder and harder to justify working on softmac.
> 
> So what are the chances of getting this dscape stack merged, let's
> say... for 2.6.19 ? Or we'll get yet another full release with barely
> working wireless ?

I don't think it's possible to happen for 2.6.19.
Ealiest 2.6.20 but likely one or two releases later (me thinks).

-- 
Greetings Michael.
