From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH iproute2] red: Add adaptative algo
Date: Thu, 19 Jan 2012 17:33:18 -0800
Message-ID: <20120119173318.00000c73@unknown>
References: <1323385900.2529.12.camel@edumazet-laptop>
	<20111208164426.03248ca8@nehalam.linuxnetplumber.net>
	<1323403837.2529.14.camel@edumazet-laptop>
	<20111209093309.04b32e27@nehalam.linuxnetplumber.net>
	<1323455459.4016.7.camel@edumazet-laptop>
	<20120119144711.359077d6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47645 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367Ab2ATBdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 20:33:20 -0500
In-Reply-To: <20120119144711.359077d6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2012 14:47:11 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Fri, 09 Dec 2011 19:30:59 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Enable Adaptative RED algo, using :
> > 
> > tc qdisc  ... red limit BYTES ... adaptative ...

...

> 
> Applied, but man page also needs update!

nit, but, if at all possible can you please spell "adaptive" correctly
especially since this is in a user interface.  I can send a patch but
was not going to get to it immediately and wanted to mention it.
