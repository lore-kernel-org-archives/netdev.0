From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] sky2: disable support for 88E8056
Date: Thu, 19 Apr 2007 15:03:12 -0400
Message-ID: <4627BCF0.90608@garzik.org>
References: <20070411214757.194710334@linux-foundation.org> <20070411214859.649647641@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59952 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766919AbXDSTDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 15:03:16 -0400
In-Reply-To: <20070411214859.649647641@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This device is having all sorts of problems that lead to data corruption
> and system instability.  It gets receive status and data out of order,
> it generates descriptor and TSO errors, etc.
> 
> Until the problems are resolved, it should not be used by anyone
> who cares about there system.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-6


