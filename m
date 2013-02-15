From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] xen-netback: fix oopes during shutdown and error
 handling
Date: Fri, 15 Feb 2013 08:45:11 +0000
Message-ID: <1360917911.25448.9.camel@zakaz.uk.xensource.com>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
	 <511D5DDF.7040000@theshore.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Beulich <jbeulich@suse.com>,
	"Wei Liu (3P)" <wei.liu@citrix.com>
To: "Christopher S. Aker" <caker@theshore.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:19481 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935450Ab3BOIpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 03:45:13 -0500
In-Reply-To: <511D5DDF.7040000@theshore.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 21:57 +0000, Christopher S. Aker wrote:
> On 2/14/13 8:18 AM, David Vrabel wrote:
> > These two netback patches fix oopes that may occur during shutdown or
> > if a specific fatal error occurs.
> 
> On 2/14/13 11:39 AM, Ian Campbell wrote:
> > Although I would like to add a Tested-by: Christopher too if
> > possible.
> 
> Tested-by: Christopher S. Aker <caker@theshore.net> (and team)

Thank you!

> We are no longer able to trigger the last OOPs we provided by downing 
> the vif.  Further testing of the other issues will take time, but we're 
> deploying a few patched hosts now.

Great, please let me know how you get on.

Ian.
