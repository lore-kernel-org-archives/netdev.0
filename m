From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: multicast: bug or "feature"
Date: Wed, 17 Oct 2007 21:20:34 -0400
Message-ID: <4716B4E2.9040609@hp.com>
References: <OFD60CD2B7.B3E2F68F-ON88257377.007EFD45-88257377.007F4B08@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:36263 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759055AbXJRBVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 21:21:33 -0400
In-Reply-To: <OFD60CD2B7.B3E2F68F-ON88257377.007EFD45-88257377.007F4B08@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



David Stevens wrote:
> You're joining the group on interface eth1, which is the
> sender, right?

I may have switched the ordering in the last test I ran,
but I always join the group on the interface different
from the one I send on.

-vlad
