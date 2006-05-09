From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual
	network	device	driver.
Date: Tue, 09 May 2006 23:26:03 +1000
Message-ID: <E1FdSDz-0008Lv-00@gondolin.me.apana.org.au>
References: <20060509131632.GB7834@cl.cam.ac.uk>
Cc: xen-devel@lists.xensource.com, herbert@gondor.apana.org.au,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org, ian.pratt@xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Christian.Limpach@cl.cam.ac.uk (Christian Limpach)
In-Reply-To: <20060509131632.GB7834@cl.cam.ac.uk>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Christian Limpach <Christian.Limpach@cl.cam.ac.uk> wrote:
> 
> Possibly having to page in the process and switching to it would add
> to the live migration time.  More importantly, having to install an
> additional program in the guest is certainly not very convenient.

Sorry I'm still not convinced.  What's there to stop me from suspending
my laptop to disk, moving it from port A to port B and resuming it?

Wouldn't I be in exactly the same situation? By the same reasoning we'd
be adding a gratuitous ARP routine to every single laptop network driver.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
