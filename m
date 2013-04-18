From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 4/5] vxlan: add scope_id support for ll addr
Date: Thu, 18 Apr 2013 21:36:45 +0800
Message-ID: <1366292205.2726.0.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-5-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934912Ab3DRNhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 09:37:53 -0400
In-Reply-To: <1366175423-27310-5-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-17 at 13:10 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> As David suggested, we should support ll addr, which requires
> scope id.

David, any comments on this patch? I am not sure it is correct.
