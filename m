From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] sky2: FE+ vlan workaround
Date: Thu, 27 Sep 2007 23:35:20 -0400
Message-ID: <46FC7678.7070102@pobox.com>
References: <20070926175847.706025d0@freepuppy.rosehill> <20070927123244.0257ab86@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57135 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755443AbXI1DfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 23:35:22 -0400
In-Reply-To: <20070927123244.0257ab86@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch applies to 2.6.23-rc8 after yesterday's patch:
>       sky2 FE+ receive status workaround

Applied.  Please always put meta-information such as the above quoted 
after the "---" patch description terminator, so that it is not copied 
into the permanent kernel changelog.  This text must be hand-edited out 
of each patch, before application.

See item #14 of Documentation/SubmittingPatches.

