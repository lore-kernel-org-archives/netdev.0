From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RESEND 2/3] netfilter: xt_condition: change the value
 from boolean to u32
Date: Wed, 15 Sep 2010 22:41:40 +0200
Message-ID: <4C912F84.9030809@trash.net>
References: <1282034213-1829-1-git-send-email-luciano.coelho@nokia.com> <1282034213-1829-3-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jengelh@medozas.de, sameo@linux.intel.com, janne.ylalehto@nokia.com
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59097 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754375Ab0IOUmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 16:42:33 -0400
In-Reply-To: <1282034213-1829-3-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 17.08.2010 10:36, schrieb Luciano Coelho:
>  static struct xt_match condition_mt_reg __read_mostly = {
>  	.name       = "condition",
> -	.revision   = 1,
> +	.revision   = 2,

Is this previous version actually compatible with anything that has
ever been released?
