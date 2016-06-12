From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHi next] veth: advertise peer link relationship for both
 devices
Date: Sat, 11 Jun 2016 19:30:19 -0700 (PDT)
Message-ID: <20160611.193019.365613971876579784.davem@davemloft.net>
References: <1465576339-17641-1-git-send-email-lrichard@redhat.com>
	<20160611.154340.1340829899277605940.davem@davemloft.net>
	<489378018.52267492.1465697053847.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081AbcFLCaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 22:30:21 -0400
In-Reply-To: <489378018.52267492.1465697053847.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Sat, 11 Jun 2016 22:04:13 -0400 (EDT)

> I'll confess to not being super-happy with it myself, which is why I've
> been sitting on this patch for some time now. A hard NAK will help justify
> a "will not fix" to the reporter of this issue.

Since userspace can learn everything is needs to using the existing
notifications, there is no reason for this change, NACK.
