From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: fix description of expected checkentry return
 code on xt_target
Date: Thu, 20 May 2010 15:59:46 +0200
Message-ID: <4BF54052.2060103@trash.net>
References: <1274126430-13744-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53129 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199Ab0ETN7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 09:59:45 -0400
In-Reply-To: <1274126430-13744-1-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luciano Coelho wrote:
> The text describing the return codes that are expected on calls to
> checkentry() was incorrect.  Instead of returning true or false, or an error
> code, it should return 0 or an error code.

Applied, thanks.
