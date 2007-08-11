From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [RFT] sky2: backport patch
Date: Fri, 10 Aug 2007 17:46:09 -0700
Message-ID: <20070811004609.GA18327@kroah.com>
References: <Pine.LNX.4.64.0708072043340.16599@bizon.gios.gov.pl> <20070807185631.GA19140@kroah.com> <20070807171415.6892a070@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stable@kernel.org,
	Krzysztof Oledzki <olel@ans.pl>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37472 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754956AbXHKAqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 20:46:18 -0400
Content-Disposition: inline
In-Reply-To: <20070807171415.6892a070@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2007 at 05:14:15PM -0400, Stephen Hemminger wrote:
> Any volunteers to test this, it has a backport for the three main stability patches:
>  1. carrier management
>  2. lost irq timer
>  3. rechecking for packets in poll
>  4. overlength packet hang.
> 
> I am away from any sky2 hardware for another week, but others maybe
> able to validate this.

Care to break these down into 3 patches and send them to stable@ if you
get the chance?

thanks,

greg k-h
