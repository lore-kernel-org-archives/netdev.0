From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [patch 26/26] Xen-paravirt_ops: Add the Xen virtual
	network device driver.
Date: Thu, 1 Mar 2007 17:26:58 -0800
Message-ID: <20070302012658.GB10574@sequoia.sous-sol.org>
References: <20070301232443.195603797@goop.org>
	<20070301232529.648076372@goop.org>
	<20070301164214.4a40bc59@freekitty>
	<20070302012102.GA15252@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>, Andi Kleen <ak@muc.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, Chris Wright <chrisw@sous-sol.org>,
	Zachary Amsden <zach@vmware.com>, Rusty Russell <rusty@rustcorp.com.au>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
Content-Disposition: inline
In-Reply-To: <20070302012102.GA15252@infradead.org>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

* Christoph Hellwig (hch@infradead.org) wrote:
> Actually the right way to do it is in userspace, as all clustering
> solutions do.  That's whay everyone told the Xen folks by the just
> refuse to rip this junk out.

I'm ripping it out.
