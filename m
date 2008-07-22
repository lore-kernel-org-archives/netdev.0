From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.26] rndis_host:  support WM6 devices as modems
Date: Tue, 22 Jul 2008 19:45:58 -0400
Message-ID: <48867136.3080805@pobox.com>
References: <200807221355.59207.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network development list <netdev@vger.kernel.org>,
	Adam Williamson <awilliamson@mandriva.com>,
	john.carr@unrouted.co.uk, Thomas Backlund <tmb@mandriva.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52563 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259AbYGVXqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 19:46:03 -0400
In-Reply-To: <200807221355.59207.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> From: Thomas Backlund <tmb@mandriva.org>
> 
> This patch allows Windows Mobile 6 devices to be used for
> tethering -- that is, used as modems.  It was requested by
> AdamW in kernel bugzilla:
> 
>   http://bugzilla.kernel.org/show_bug.cgi?id=11119
> 
> and Mandriva kernel-discuss list.  It is tested and confirmed
> to work by Peterl:
> 
>   http://forum.eeeuser.com/viewtopic.php?pid=323543#p323543
> 
> This patch is based on the patch in the above kernel bugzilla,
> which is from the usb-rndis-lite tree.
> 
> [ dbrownell@users.sourceforge.net: misc fixes ]
> Signed-off-by: Thomas Backlund <tmb@mandriva.org>
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> ---
>  drivers/net/usb/cdc_ether.c  |   11 ++++++++++-
>  drivers/net/usb/rndis_host.c |    4 ++++
>  2 files changed, 14 insertions(+), 1 deletion(-)

applied


