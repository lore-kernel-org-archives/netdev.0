From: Greg KH <greg@kroah.com>
Subject: Re: netlink: Add missing goto statement to netlink_insert
Date: Tue, 8 Dec 2015 22:29:51 -0500
Message-ID: <20151209032951.GJ17525@kroah.com>
References: <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
 <565EBDC1.1090808@profihost.ag>
 <8737vlt6xb.fsf@stressinduktion.org>
 <5661DAC4.8040909@profihost.ag>
 <20151205010819.GA21889@gondor.apana.org.au>
 <5664A102.2030602@profihost.ag>
 <20151207012042.GA7420@gondor.apana.org.au>
 <56652E11.4010604@profihost.ag>
 <20151208061319.GA16209@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Weimer <fweimer@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	jannik Winkel <j.winkel@profihost.ag>,
	Marco Schinkel <m.schinkel@profihost.ag>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151208061319.GA16209@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 08, 2015 at 02:13:19PM +0800, Herbert Xu wrote:
> On Mon, Dec 07, 2015 at 07:58:25AM +0100, Stefan Priebe - Profihost AG wrote:
> >
> > Thanks, good. Can you help me to get this fix upstream into the stable
> > lines?
> 
> Sure.  Greg, please apply this patch to fix up the backport for 4.1.

Now queued up, thanks for the fix.

greg k-h
