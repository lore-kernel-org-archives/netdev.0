From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tg3: TSO related enhancements to prevent
 memory allocation failure
Date: Tue, 13 May 2014 18:39:31 -0400 (EDT)
Message-ID: <20140513.183931.519531922477542395.davem@davemloft.net>
References: <1399864975-29070-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, prashant@broadcom.com, ivecera@redhat.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890AbaEMWjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 18:39:33 -0400
In-Reply-To: <1399864975-29070-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Sun, 11 May 2014 20:22:52 -0700

> Michael Chan (3):
>   tg3: Don't modify ip header fields when doing GSO
>   tg3: Prevent page allocation failure during TSO workaround
>   tg3: Update copyright and version to 3.137

Series applied, thanks Michael.
