From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skbuff: improve comment on checksumming
Date: Thu, 19 Dec 2013 14:53:25 -0500 (EST)
Message-ID: <20131219.145325.146425667686671038.davem@davemloft.net>
References: <1387232829-4469-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755991Ab3LSTx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:53:27 -0500
In-Reply-To: <1387232829-4469-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 16 Dec 2013 23:27:09 +0100

> It can be a bit confusing when looking for checksumming flags that
> the actual comment for this resides elsewhere further below in the
> header file.
> 
> Thus, bring the documentation where we define these flags, and
> slightly improve the doc text to make it a bit more clear/readable.
> 
> Also, whitespace-align values of the define while at it.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks a lot.
