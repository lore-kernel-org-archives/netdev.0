From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] ptp: Fix compiler warnings in the
 testptp utility
Date: Wed, 26 Mar 2014 10:16:37 +0100
Message-ID: <20140326091636.GA5015@netboy>
References: <1395818163-31672-1-git-send-email-christian.riesch@omicron.at>
 <35ec3d13-e8a8-4cf4-b5ce-91c4dbe2ac0b@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dong Zhu <bluezhudong@gmail.com>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:51590 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbaCZJQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 05:16:42 -0400
Received: by mail-ee0-f53.google.com with SMTP id b57so1389497eek.12
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 02:16:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <35ec3d13-e8a8-4cf4-b5ce-91c4dbe2ac0b@mary.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 08:16:03AM +0100, Christian Riesch wrote:
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
> Cc: Dong Zhu <bluezhudong@gmail.com>
> ---
> 
> Changes for v2:
> - Use PRI64d macro for __s64 in printf

Acked-by: Richard Cochran <richardcochran@gmail.com>
