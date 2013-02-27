From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Wed, 27 Feb 2013 14:09:22 -0500 (EST)
Message-ID: <20130227.140922.297055134527931147.davem@davemloft.net>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
	<20130227.130959.379760800169434112.davem@davemloft.net>
	<D64EC45690EF85409BA6C4730E0162244310EF1F@G4W3231.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lee.roberts@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760542Ab3B0TJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 14:09:25 -0500
In-Reply-To: <D64EC45690EF85409BA6C4730E0162244310EF1F@G4W3231.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Roberts, Lee A." <lee.roberts@hp.com>
Date: Wed, 27 Feb 2013 18:55:36 +0000

> I missed the change in the calling sequence for sctp_ulpq_partial_delivery()
> when porting the changes forward from 3.2.x.  An updated patch has been sent.

Thanks.  But please CC: the SCTP maintainers or at least CC: the
linux-sctp list, as well as netdev, when you post SCTP patches,
thanks.
