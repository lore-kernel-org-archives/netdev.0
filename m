From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] bonding: support for IPv6 transmit hashing
Date: Tue, 21 Aug 2012 22:29:25 -0700 (PDT)
Message-ID: <20120821.222925.547404133757422143.davem@davemloft.net>
References: <eb20e8f67e6aad94c233219e058c3e793ed755cb.1341167171.git.linux@8192.net>
	<2e01d8f94c42c61af9886683a4c35caf6816bc3d.1345610688.git.linux@8192.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@8192.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab2HVF32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 01:29:28 -0400
In-Reply-To: <2e01d8f94c42c61af9886683a4c35caf6816bc3d.1345610688.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Eaglesham <linux@8192.net>
Date: Tue, 21 Aug 2012 22:12:33 -0700

> Signed-off-by: John Eaglesham

This is not a proper signoff, you must put an email address on this line.

Also, the changelog between the versions doesn't belong in the commit
log message itself.  It gets placed in commentary after the "---" line.
