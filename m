From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sky2: sky2 FE+ receive status workaround
Date: Thu, 27 Sep 2007 23:33:30 -0400
Message-ID: <46FC760A.8050002@garzik.org>
References: <20070926175847.706025d0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49825 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755317AbXI1Ddh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 23:33:37 -0400
In-Reply-To: <20070926175847.706025d0@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Patch against 2.6.23-rc8, please apply before 2.6.23 release (or it will
> need to go to stable).


Applied.  Please always put meta-information such as the above quoted 
after the "---" patch description terminator, so that it is not copied 
into the permanent kernel changelog.  This text must be hand-edited out 
of each patch, before application.

