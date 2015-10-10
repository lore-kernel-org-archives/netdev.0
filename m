From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] bnxt_en: New Broadcom ethernet driver.
Date: Sat, 10 Oct 2015 08:51:12 -0700
Message-ID: <1444492272.8012.7.camel@perches.com>
References: <1444477151-2225-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0113.hostedemail.com ([216.40.44.113]:50419 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750884AbbJJPvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 11:51:15 -0400
In-Reply-To: <1444477151-2225-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-10-10 at 07:39 -0400, Michael Chan wrote:
> Broadcom ethernet driver for the new family of NetXtreme-C/E
> ethernet devices.

Thanks.

In addition to the kbuild test robot suggestions,
you might try running scripts/checkpatch.pl on this
and fix up some style trivia.

Maybe try "scripts/checkpatch.pl --fix-inplace" for
the mechanical stuff.
