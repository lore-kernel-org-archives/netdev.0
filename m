From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] vxge: use strcpy for strings
Date: Wed, 01 Dec 2010 13:02:34 -0800 (PST)
Message-ID: <20101201.130234.233700600.davem@davemloft.net>
References: <1291089767-18864-1-git-send-email-jon.mason@exar.com>
	<1291089767-18864-2-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, ram.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49563
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757127Ab0LAVCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 16:02:07 -0500
In-Reply-To: <1291089767-18864-2-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Mon, 29 Nov 2010 22:02:46 -0600

> Use strncpy instead of memcpy when working on strings
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>

Applied to net-next-2.6
