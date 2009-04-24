From: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [1/2] tun: Only free a netdev when all tun descriptors
	are closed
Date: Fri, 24 Apr 2009 14:40:35 +0200
Message-ID: <200904241440.36319.borntraeger@de.ibm.com>
References: <20090415083610.GA8579@gondor.apana.org.au>
	<200904241055.49794.borntraeger@de.ibm.com>
	<20090424121156.GA28039@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, virtualization-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
	Matias Zabaljauregui <zabaljauregui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
In-Reply-To: <20090424121156.GA28039-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Friday 24 April 2009 14:11:56 schrieb Herbert Xu:
> The patch you qouted has been superceded by many versions :)

Yes, I got lost in this mail thread...

> Can you please test the latest that's in davem's tree?

Done. With 
http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Fdavem%2Fnet-2.6.git;a=commitdiff_plain;h=9c3fea6ab04a7bd9298e635bf29b4a5379f6c476
http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Fdavem%2Fnet-2.6.git;a=commitdiff_plain;h=c40af84a6726f63e35740d26f841992e8f31f92c

Everything works fine. Thank you and sorry for the noise.

Christian
