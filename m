From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: downgrade "valid ME register value" message
 level
Date: Thu, 19 Dec 2013 15:17:00 -0500 (EST)
Message-ID: <20131219.151700.926031443626638563.davem@davemloft.net>
References: <1387302685-32314-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085Ab3LSURE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:17:04 -0500
In-Reply-To: <1387302685-32314-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Tue, 17 Dec 2013 18:51:25 +0100

> "valid ME register value" is not an error. It should be logged for
> debugging only.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thanks.
