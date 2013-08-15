From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: sync some IP headers with glibc
Date: Thu, 15 Aug 2013 01:44:44 -0700 (PDT)
Message-ID: <20130815.014444.2206565736884581460.davem@davemloft.net>
References: <1376383054-9184-1-git-send-email-amwang@redhat.com>
	<20130814.134246.1152657041177088716.davem@davemloft.net>
	<1376556163.2626.11.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tmb@mageia.org, libc-alpha@sourceware.org,
	yoshfuji@linux-ipv6.org, carlos@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab3HOIop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 04:44:45 -0400
In-Reply-To: <1376556163.2626.11.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 15 Aug 2013 16:42:43 +0800

> Hmm, for this one, the original format is hard to keep since this patch
> changes macros to enum's. What this patch does here looks correct to me,
> for reference, below is the original code:

Fair enough, please resubmit your patches.
