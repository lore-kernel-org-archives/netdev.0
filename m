From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: Fix initialize after use for 3ad machine state
 spinlock
Date: Mon, 18 Feb 2013 18:56:18 +0100
Message-ID: <51226B42.7020400@redhat.com>
References: <1361191541-7654-1-git-send-email-nikolay@redhat.com> <20130218.120232.679284201789150959.davem@davemloft.net> <51226831.4030105@redhat.com> <20130218.124422.842748240449456145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756391Ab3BRR4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 12:56:38 -0500
In-Reply-To: <20130218.124422.842748240449456145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/02/13 18:44, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@redhat.com>
> Date: Mon, 18 Feb 2013 18:43:13 +0100
> 
>> Should I post a v2 with numbering ?
> 
> You should resubmit all 3 bonding patches you submitted, with proper
> numbering.
Okay, will do. Just to note 2 of the patches are for net, and 1 is for
the net-next tree. That information will be included in the subject as
usual.

Thanks,
 Nik
