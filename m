From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] xen: use less generic names in netfront
	driver.
Date: Sun, 22 Aug 2010 21:44:34 -0700 (PDT)
Message-ID: <20100822.214434.13761837.davem@davemloft.net>
References: <1282210055.3170.2283.camel@zakaz.uk.xensource.com>
	<1282210070-7745-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeremy@goop.org, xen-devel@lists.xensource.com,
	jeremy.fitzhardinge@citrix.com
To: ian.campbell@citrix.com
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1282210070-7745-1-git-send-email-ian.campbell@citrix.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

From: Ian Campbell <ian.campbell@citrix.com>
Date: Thu, 19 Aug 2010 10:27:49 +0100

> All Xen frontend drivers have a couple of identically named functions which
> makes figuring out which device went wrong from a stacktrace harder than it
> needs to be. Rename them to something specificto the device type.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

Applied.
