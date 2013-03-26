From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: remove already created master sysfs link on
 failure
Date: Tue, 26 Mar 2013 13:00:52 -0400 (EDT)
Message-ID: <20130326.130052.1023642948377023108.davem@davemloft.net>
References: <1364316208-1068-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072Ab3CZRAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 13:00:54 -0400
In-Reply-To: <1364316208-1068-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 26 Mar 2013 17:43:28 +0100

> If slave sysfs symlink failes to be created - we end up without removing
> the master sysfs symlink. Remove it in case of failure.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied and queued up for -stable, thanks.
