From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network
	device driver.
Date: Thu, 11 May 2006 19:30:20 +0200
Message-ID: <200605111930.20852.ak@suse.de>
References: <E1Fdz7v-0007zc-00@gondolin.me.apana.org.au>
	<200605111147.53011.ak@suse.de> <44636ACB.4020705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, tytso@mit.edu,
	Herbert Xu <herbert@gondor.apana.org.au>,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	rdreier@cisco.com, linux-kernel@vger.kernel.org,
	chrisw@sous-sol.org, ian.pratt@xensource.com, shemminger@osdl.org
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <44636ACB.4020705@hp.com>
Content-Disposition: inline
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Thursday 11 May 2006 18:48, Rick Jones wrote:
>  From the peanut gallery...
> 
> Can remote TCP ISN's be considered a source of entropy these days?  How 
> about checksums?

Indirectly - we measure how long it takes to compute them.

-Andi
