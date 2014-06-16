From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: In the testptp utility, use clock_adjtime from
 glibc when available
Date: Mon, 16 Jun 2014 18:26:41 +0200
Message-ID: <20140616162641.GA3732@localhost.localdomain>
References: <1402922805-3664-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:61906 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbaFPQ1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 12:27:08 -0400
Received: by mail-we0-f171.google.com with SMTP id q58so5921958wes.2
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 09:27:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1402922805-3664-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 02:46:45PM +0200, Christian Riesch wrote:
> clock_adjtime was included in glibc 2.14. _GNU_SOURCE must be defined
> to make it available.

Acked-by: Richard Cochran <richardcochran@gmail.com>
