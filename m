From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next stable v2] sctp: fully initialize sctp_outq in
 sctp_outq_init
Date: Thu, 13 Jun 2013 18:06:18 -0700 (PDT)
Message-ID: <20130613.180618.994297187695379192.davem@redhat.com>
References: <1371061604-27312-1-git-send-email-nhorman@tuxdriver.com>
	<20130613.024453.1256276769178191648.davem@davemloft.net>
	<20130613130849.GA4058@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	vyasevich@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29745 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412Ab3FNBG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 21:06:29 -0400
In-Reply-To: <20130613130849.GA4058@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 13 Jun 2013 09:08:49 -0400

> On Thu, Jun 13, 2013 at 02:44:53AM -0700, David Miller wrote:
>> 
>> 'net-next' + 'stable' is an invalid set of targets for a patch.
>> 
>> If the patch is appropriate for 'stable', then it had better be
>> appropriate for plain 'net' as well.
>> 
> Sorry, I just meant to indicate that I had initially applied it to net-next.  I
> had meant to add net in there as well, where it also applies cleanly

Applied to 'net' and queued up for -stable, thanks!
