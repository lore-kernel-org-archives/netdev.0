From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: use strlcpy with ethtool_drvinfo fields
Date: Sun, 06 Jan 2013 21:12:44 -0800 (PST)
Message-ID: <20130106.211244.527400136761812263.davem@davemloft.net>
References: <1357390390-16549-1-git-send-email-fbl@redhat.com>
	<1357395077.4324.5.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, netdev@vger.kernel.org, jpirko@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757Ab3AGFMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:12:45 -0500
In-Reply-To: <1357395077.4324.5.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 5 Jan 2013 14:11:17 +0000

> On Sat, 2013-01-05 at 10:53 -0200, Flavio Leitner wrote:
>> The fields must be null-terminated.
>> 
>> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> 
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
