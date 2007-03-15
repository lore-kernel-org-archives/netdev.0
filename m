From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 5/6] [TULIP]  Fix SytemError typo
Date: Thu, 15 Mar 2007 11:29:09 -0400
Message-ID: <45F96645.2000803@garzik.org>
References: <20070312093128.577087000@linux.intel.com> <20070312184218.739924000@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org
To: Valerie Henson <val_henson@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50435 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422887AbXCOP3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 11:29:15 -0400
In-Reply-To: <20070312184218.739924000@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valerie Henson wrote:
> Fix an annoying typo - SytemError -> SystemError
> 
> Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> 
> ---
>  drivers/net/tulip/interrupt.c   |    4 ++--
>  drivers/net/tulip/tulip.h       |    2 +-
>  drivers/net/tulip/winbond-840.c |    2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)

applied 5-6, after fixing the subject lines.

Please note that anything in the subject line between '[' and ']', 
inclusive, is stripped before applying to the kernel.  Thus, your 
'[TULIP]' identifier, which tells people which area of the kernel you 
are modifying, is stripped.

You want to use a subject line like

	[patch 4/6] tulip: fix SytemError typo

For more info see http://linux.yyz.us/patch-format.html and 
Documentation/SubmittingPatches.

	Jeff



