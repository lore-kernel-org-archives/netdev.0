From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 0/9] net: introduce generic type and helpers
 for IP address
Date: Thu, 22 Aug 2013 12:53:28 +0800
Message-ID: <1377147208.8703.10.camel@cr0>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
	 <20130820.231159.2092592990953992941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707Ab3HVExf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 00:53:35 -0400
In-Reply-To: <20130820.231159.2092592990953992941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-20 at 23:11 -0700, David Miller wrote:
> 
> That's why all these places use a different data structure!  They have
> different needs.  Can you see that?
> 

No problem, then let's drop this patchset.
And I will continue to duplicate the code in my VXLAN patchset.

Thanks.
