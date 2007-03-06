From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [RFC] ARP notify option
Date: Tue, 6 Mar 2007 11:07:33 -0800
Message-ID: <20070306190733.GY10574@sequoia.sous-sol.org>
References: <20070301164214.4a40bc59@freekitty> <45E7764A.7000100@goop.org>
	<20070301173030.754514ec@freekitty>
	<20070305.203536.92584097.davem@davemloft.net>
	<20070306105132.52c77491@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zach@vmware.com, jeremy@goop.org, xen-devel@lists.xensource.com,
	jeff@garzik.org, ian.pratt@xensource.com, ak@muc.de,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, akpm@linux-foundation.org,
	David Miller <davem@davemloft.net>, Christian.Limpach@cl.cam.ac.uk
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
Content-Disposition: inline
In-Reply-To: <20070306105132.52c77491@freekitty>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

* Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> This adds another inet device option to enable gratuitous ARP
> when device is brought up or address change. This is handy for
> clusters or virtualization.

This looks good.  I'll test with Xen.  What about the source
addr selection?

thanks,
-chris
