From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC] Arp announce (for Xen)
Date: 2 Mar 2007 13:54:28 +0100
Message-ID: <20070302125428.GA67405@muc.de>
References: <20070301232443.195603797@goop.org>
	<20070301232529.648076372@goop.org>
	<20070301164214.4a40bc59@freekitty> <45E7764A.7000100@goop.org>
	<20070301173030.754514ec@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zachary Amsden <zach@vmware.com>, Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel@lists.xensource.com, Jeff Garzik <jeff@garzik.org>,
	Ian Pratt <ian.pratt@xensource.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>,
	virtualization@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
Date: Fri, 2 Mar 2007 13:54:28 +0100
Content-Disposition: inline
In-Reply-To: <20070301173030.754514ec@freekitty>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2007 at 05:30:30PM -0800, Stephen Hemminger wrote:
> What about implementing the unused arp_announce flag on the inetdevice?
> Something like the following.  Totally untested...
> 
> Looks like it either was there (and got removed) or was planned but
> never implemented.

Seems like the right solution to me (if it works)

-Andi
