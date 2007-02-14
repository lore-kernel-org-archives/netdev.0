From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH][NET][BRIDGE] br_if: oops in port_carrier_check
Date: Wed, 14 Feb 2007 09:07:58 +0100
Message-ID: <20070214080758.GA1972@ff.dom.local>
References: <20070212094738.0a8ae896@localhost.localdomain> <20070213062650.GA1614@ff.dom.local> <20070213115529.6ea7e7bd@freekitty> <20070213.123553.38710118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	pterjan@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:52094 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751262AbXBNIEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 03:04:47 -0500
Content-Disposition: inline
In-Reply-To: <20070213.123553.38710118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 12:35:53PM -0800, David Miller wrote:
...
> I've applied this patch, thanks everyone.
> 
> Stephen, do we want this in -stable?
 
I got this info it went trough -mm too:

...
> From: akpm@linux-foundation.org
> Subject: - br_if-oops-in-port_carrier_check.patch removed from -mm tree
> To: jarkao2@o2.pl, mm-commits@vger.kernel.org
...
> The patch titled
>     br_if: oops in port_carrier_check
> has been removed from the -mm tree.  Its filename was
>     br_if-oops-in-port_carrier_check.patch
>
> This patch was dropped because it was merged into mainline or a subsystem tree

Regards,
Jarek P.
