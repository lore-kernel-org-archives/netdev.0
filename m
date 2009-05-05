From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-2.6 2009-05-05
Date: Tue, 05 May 2009 13:55:52 -0700 (PDT)
Message-ID: <20090505.135552.236556477.davem@davemloft.net>
References: <1241556539.2987.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753151AbZEEUz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 16:55:57 -0400
In-Reply-To: <1241556539.2987.31.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 05 May 2009 13:48:59 -0700

> this is kinda embarrassing since I did ack the initial dev_set_name()
> change for 2.6.28, but at that point it was not allocating any memory
> and so nobody ran into any problems with it. However with 2.6.30 it is
> allocating memory with GFP_KERNEL and so we have to move it. The change
> is simple and straight forward.
 ...
>     git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

Ho hum... pulled, thanks.
