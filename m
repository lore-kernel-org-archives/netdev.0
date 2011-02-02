From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bna: use device model DMA API
Date: Wed, 02 Feb 2011 15:03:08 -0800 (PST)
Message-ID: <20110202.150308.246520172.davem@davemloft.net>
References: <1296657422-13537-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com, ddutt@brocade.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755387Ab1BBXCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:02:33 -0500
In-Reply-To: <1296657422-13537-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed,  2 Feb 2011 15:37:02 +0100

> Use DMA API as PCI equivalents will be deprecated.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Looks good to me, can we get some review from the BNA maintainers
please?
