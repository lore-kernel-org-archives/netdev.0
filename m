From: David Miller <davem@davemloft.net>
Subject: Re: remove noisy message from llcp_sock_sendmsg
Date: Thu, 13 Dec 2012 13:01:14 -0500 (EST)
Message-ID: <20121213.130114.1371460838800683919.davem@davemloft.net>
References: <20121213041134.GA1611@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755865Ab2LMSBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 13:01:18 -0500
In-Reply-To: <20121213041134.GA1611@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 12 Dec 2012 23:11:34 -0500

> This is easily triggerable when fuzz-testing as an unprivileged user.
> We could rate-limit it, but given we don't print similar messages
> for other protocols, I just removed it.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied.

Please provide appropriate "xxx: " prefixes in your subject lines
for patch submissions.  "nfc: " would have been appropriate for
this one.

Thanks.
