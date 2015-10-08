From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: constify the sock parameter in unix_sk()
Date: Thu, 08 Oct 2015 04:08:06 -0700 (PDT)
Message-ID: <20151008.040806.1522361874279906150.davem@davemloft.net>
References: <20151006190353.7311.36864.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922AbbJHKwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 06:52:19 -0400
In-Reply-To: <20151006190353.7311.36864.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Tue, 06 Oct 2015 15:03:53 -0400

> Make unix_sk() just like inet[6]_sk() by constify'ing the sock
> parameter.
> 
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Applied, thanks Paul.
