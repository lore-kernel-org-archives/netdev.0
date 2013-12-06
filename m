From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] forcedeth: run loopback test only on chipsets that
 support it
Date: Thu, 05 Dec 2013 21:01:14 -0500 (EST)
Message-ID: <20131205.210114.237609601566960224.davem@davemloft.net>
References: <1386176811-7114-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727Ab3LFCBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 21:01:15 -0500
In-Reply-To: <1386176811-7114-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed,  4 Dec 2013 18:06:51 +0100

> The driver incorrectly run loopback test on chips that don't support it.
> Loopback test is only supported by chips that has DEV_HAS_TEST_EXTENDED
> flag and returns 4 (NV_TEST_COUNT_EXTENDED) as test count.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied.
