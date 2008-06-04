From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Cleanup use of deprecated calls to save_and_cli and
 restore_flags.
Date: Wed, 04 Jun 2008 12:06:36 -0700 (PDT)
Message-ID: <20080604.120636.167448431.davem@davemloft.net>
References: <1212509959-8763-1-git-send-email-mark.asselstine@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: mark.asselstine@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48058
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754221AbYFDTGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 15:06:36 -0400
In-Reply-To: <1212509959-8763-1-git-send-email-mark.asselstine@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Asselstine <mark.asselstine@windriver.com>
Date: Tue,  3 Jun 2008 12:19:19 -0400

> Make use of local_irq_save and local_irq_restore rather then the
> deprecated save_and_cli and restore_flags calls.
> 
> Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>

Applied, thanks.
