From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v1] usbnet: re-use native hex2bin()
Date: Fri, 23 Jan 2015 09:12:39 +0100
Message-ID: <1422000759.16104.0.camel@linux-0dmf.site>
References: <1421962032-25497-1-git-send-email-andy.shevchenko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33622 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751849AbbAWIMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jan 2015 03:12:52 -0500
In-Reply-To: <1421962032-25497-1-git-send-email-andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-22 at 23:27 +0200, Andy Shevchenko wrote:
> Call hex2bin() library function, instead of doing conversion here.
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Acked-by: Oliver Neukum <oneukum@suse.de>
