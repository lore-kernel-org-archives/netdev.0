From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: use device model DMA API
Date: Wed, 02 Feb 2011 14:57:17 -0800 (PST)
Message-ID: <20110202.145717.115924988.davem@davemloft.net>
References: <1296669912-26563-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathyap@serverengines.com,
	subbus@serverengines.com, sarveshwarb@serverengines.com,
	ajitk@serverengines.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755268Ab1BBW4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 17:56:41 -0500
In-Reply-To: <1296669912-26563-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed,  2 Feb 2011 19:05:12 +0100

> Use DMA API as PCI equivalents will be deprecated.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Looks good to me, can I get some review from the be2net maintainers?
