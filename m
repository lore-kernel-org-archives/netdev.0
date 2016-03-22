From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] ipv4: initialize flowi4_flags before calling
 fib_lookup()
Date: Tue, 22 Mar 2016 16:03:54 -0400 (EDT)
Message-ID: <20160322.160354.71451748339737444.davem@redhat.com>
References: <1458673017-3528-1-git-send-email-lrichard@redhat.com>
	<688989936.72666829.1458673139415.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33160 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696AbcCVUD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 16:03:56 -0400
In-Reply-To: <688989936.72666829.1458673139415.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Tue, 22 Mar 2016 14:58:59 -0400 (EDT)

> Apologies, that should have been [PATCH v2 net].

No worries.

Applied and queued up for -stable, thanks.
