From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] cls_u32 hardware offload fixes
Date: Tue, 07 Jun 2016 16:27:31 -0700 (PDT)
Message-ID: <20160607.162731.1154473267162142674.davem@davemloft.net>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	sridhar.samudrala@intel.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbcFGX1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:27:32 -0400
In-Reply-To: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon,  6 Jun 2016 16:16:46 +0100

> This set fixes two small issues with error codes I noticed
> in cls_u32.  Second patch could be viewed as user space API
> change but that portion of API is not part of any release,
> yet.
> 
> Compile tested only.

Applied, thanks.
