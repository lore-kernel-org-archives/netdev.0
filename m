From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c509.c: call SET_NETDEV_DEV for all device types
 (ISA/ISAPnP/EISA)
Date: Thu, 25 Apr 2013 01:45:06 -0400 (EDT)
Message-ID: <20130425.014506.1913208306260076817.davem@davemloft.net>
References: <CAP8WD_ZJo_RaShD-V5fn4OUySt8_RCdjyZvVpijhhQEZQZHkbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab3DYFpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:45:07 -0400
In-Reply-To: <CAP8WD_ZJo_RaShD-V5fn4OUySt8_RCdjyZvVpijhhQEZQZHkbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Tue, 23 Apr 2013 13:49:39 -0400

> Tested on ISA and EISA boards.

You didn't actually test "this" patch.

> @@ -306,6 +306,7 @@ static int el3_isa_match(struct device *pdev,
> unsigned int ndev)

Because it was corrupted by your email client, long lines were
chopped up, etc.

Please fix this, send a test patch to yourself, and do not resubmit
this patch here until you are able to successfully apply the patch
you receive in those test emails.

Thanks.
