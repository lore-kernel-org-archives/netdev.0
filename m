From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: RFC7413 option support for Fast Open
 server
Date: Tue, 07 Apr 2015 18:39:57 -0400 (EDT)
Message-ID: <20150407.183957.203585611362799938.davem@davemloft.net>
References: <1428356247-10262-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Longinus00@gmail.com, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbbDGWj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 18:39:59 -0400
In-Reply-To: <1428356247-10262-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon,  6 Apr 2015 14:37:26 -0700

> From: Daniel Lee <Longinus00@gmail.com>
> 
> Fast Open has been using the experimental option with a magic number
> (RFC6994) to request and grant Fast Open cookies. This patch enables
> the server to support the official IANA option 34 in RFC7413 in
> addition.
> 
> The change has passed all existing Fast Open tests with both
> old and new options at Google.
> 
> Signed-off-by: Daniel Lee <Longinus00@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
