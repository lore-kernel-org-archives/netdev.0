From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] myri10ge: allow small_bytes = 0
Date: Wed, 29 Jun 2011 06:03:02 -0700 (PDT)
Message-ID: <20110629.060302.59482200629906342.davem@davemloft.net>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	<1309187108-12715-4-git-send-email-mason@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com
To: mason@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535Ab1F2NDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 09:03:05 -0400
In-Reply-To: <1309187108-12715-4-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <mason@myri.com>
Date: Mon, 27 Jun 2011 10:05:03 -0500

> Allow page-based receive to work when small_bytes is set to 0.
> 
> Signed-off-by: Jon Mason <mason@myri.com>

Applied.
