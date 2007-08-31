From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch]support for USB autosuspend in the asix driver
Date: Fri, 31 Aug 2007 08:50:25 -0400
Message-ID: <46D80E91.3020006@pobox.com>
References: <200708031352.19419.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Brownell <david-b@pacbell.net>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34415 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933121AbXHaMu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 08:50:29 -0400
In-Reply-To: <200708031352.19419.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> Hi,
> 
> this implements support for USB autosuspend in the asix USB ethernet
> driver.
> 
> 	Regards
> 		Oliver
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

applied

please put comments like "Hi," and "Regards Oliver" below the "---" 
terminator, otherwise they must be hand-edited out to avoid scripts' 
pasting that into the permanent kernel history.


