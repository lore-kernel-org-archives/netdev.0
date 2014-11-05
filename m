From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Wed, 05 Nov 2014 15:10:47 -0500 (EST)
Message-ID: <20141105.151047.1621156460688575485.davem@davemloft.net>
References: <1415080846-1623-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaKEUKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:10:50 -0500
In-Reply-To: <1415080846-1623-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please do not submit your patches such that the email Date: field is
the commit's date.  You're not posting these on Nov. 4th, yet that
is the Date: field on all of the individual patch emails.

I want them to be the date at the time you post the patch to the mailing
list.

Otherwise the ordering in patchwork is not cronological wrt. the list's
postings and this makes my work more difficult than it needs to be.

Thanks.
