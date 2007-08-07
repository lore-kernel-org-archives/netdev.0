From: Greg KH <greg@kroah.com>
Subject: Re: [stable] sky2: workaround for lost IRQ and 2.6.22-stable
Date: Tue, 7 Aug 2007 11:56:31 -0700
Message-ID: <20070807185631.GA19140@kroah.com>
References: <Pine.LNX.4.64.0708072043340.16599@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, stable@kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:47284 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757266AbXHGUMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 16:12:34 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708072043340.16599@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2007 at 08:46:31PM +0200, Krzysztof Oledzki wrote:
>  Hello,
> 
>  http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.21.y.git;a=commitdiff;h=fe1fe7c982f86624c692644e8ed05e132f4753cc
> 
>  Is this fix going to be included in the next 2.6.22-stable release or is it 
>  not needed any more?

It's not queued up for the next 2.6.22-stable release as no one has sent
it to the stable maintainers :)

thanks,

greg k-h
