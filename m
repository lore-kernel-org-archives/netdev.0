From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: fix PM related regressions
Date: Thu, 07 Aug 2008 01:56:31 -0400
Message-ID: <489A8E8F.8060109@pobox.com>
References: <20080804133337.3c0fe889@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41687 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514AbYHGF4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 01:56:37 -0400
In-Reply-To: <20080804133337.3c0fe889@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Fix the problems reported for 2.6.27-rc1 caused by over aggressive
> power management. Turning clock off on PCI Express is problematic for WOL,
> and when doing multi-booting.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

applied


