From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] s2io: remove unused code
Date: Wed, 18 Aug 2010 14:27:08 -0700 (PDT)
Message-ID: <20100818.142708.39172176.davem@davemloft.net>
References: <1281625384-26927-1-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ramkrishna.vepa@exar.com,
	sivakumar.subramani@exar.com, sreenivasa.honnur@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60907
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751191Ab0HRV0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 17:26:49 -0400
In-Reply-To: <1281625384-26927-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Thu, 12 Aug 2010 10:03:03 -0500

> usr_addrs is never referenced outside the initial struct population
> during open, thus making it unnecessary.  Remove it, the code that
> references it, and the struct that it is the only user of.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>

Applied.
