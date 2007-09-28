From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] sky2: fix transmit state on resume
Date: Thu, 27 Sep 2007 23:35:35 -0400
Message-ID: <46FC7687.5050705@pobox.com>
References: <20070926175847.706025d0@freepuppy.rosehill> <20070927123812.4e2185f3@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57143 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754810AbXI1Dfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 23:35:36 -0400
In-Reply-To: <20070927123812.4e2185f3@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Patch is against 2.6.23-rc8 after last patch:
>  sky2: FE+ vlan workaround
> 
> (Should also work on older releases with minor fuzz).

Applied.  Please always put meta-information such as the above quoted 
after the "---" patch description terminator, so that it is not copied 
into the permanent kernel changelog.  This text must be hand-edited out 
of each patch, before application.

See item #14 of Documentation/SubmittingPatches.


