From: maximilian attems <max@stro.at>
Subject: Re: [PATCH] AX25: kill user triggable printks
Date: Wed, 9 Jan 2008 11:15:49 +0100
Message-ID: <20080109101549.GC8816@baikonur.stro.at>
References: <1199873483-8844-1-git-send-email-max@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:54001 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbYAIKRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 05:17:04 -0500
Content-Disposition: inline
In-Reply-To: <1199873483-8844-1-git-send-email-max@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 11:11:23AM +0100, maximilian attems wrote:
> +			/* support for old structure may go away some time
> +			 * ax25_sendmsg(): uses old (6 digipeater)
> +			 * socket structure.\n",
> +			 */
urrgs overseen \n",
will resend in a second.

-- 
maks
