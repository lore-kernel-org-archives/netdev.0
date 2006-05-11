From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network
	device driver.
Date: Thu, 11 May 2006 10:33:59 +1000
Message-ID: <E1Fdz7v-0007zc-00@gondolin.me.apana.org.au>
References: <200605102028.22974.ak@suse.de>
Cc: xen-devel@lists.xensource.com, ian.pratt@xensource.com,
	netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, shemminger@osdl.org
Return-path: <xen-devel-bounces@lists.xensource.com>
To: ak@suse.de (Andi Kleen)
In-Reply-To: <200605102028.22974.ak@suse.de>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> wrote:
> 
> But if sampling virtual events for randomness is really unsafe (is it 
> really?) then native guests in Xen would also get bad random numbers
> and this would need to be somehow addressed.

Good point.  I wonder what VMWare does in this situation.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
