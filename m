From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: Is: automated testing before David M picks them up? Was: Re:
 [Xen-devel] [PATCH net v2] xen-netback: bookkeep number of active queues in
 our own module
Date: Mon, 30 Jun 2014 09:39:13 +0100
Message-ID: <1404117553.3827.9.camel@kazak.uk.xensource.com>
References: <20140622.172105.1949118384610767695.davem@davemloft.net>
	 <20140623084032.GU20819@zion.uk.xensource.com>
	 <20140623153151.GA3261@laptop.dumpdata.com>
	 <20140627.123438.2145034024736949555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <konrad.wilk@oracle.com>, <netdev@vger.kernel.org>,
	<boris.ostrovsky@oracle.com>, <xen-devel@lists.xen.org>,
	<wei.liu2@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:38641 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231AbaF3IjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 04:39:15 -0400
In-Reply-To: <20140627.123438.2145034024736949555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-27 at 12:34 -0700, David Miller wrote:
> From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Date: Mon, 23 Jun 2014 11:31:51 -0400
> 
> > Having said that - how do you handle such situation with sub-maintainers
> > wanting to do some testing before they are cleared to go your way?
> 
> Who cares, the bug gets found eventually right?
> 
> There is no value in my letting changes sit for more than a day or two that
> aren't being actively discussed and look fine to me.

So perhaps Konrad ought to be feeding net{,-next}.git to his testing
framework?

Ian.
