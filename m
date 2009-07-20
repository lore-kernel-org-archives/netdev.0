From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 07:05:55 -0700 (PDT)
Message-ID: <20090720.070555.136341253.davem@davemloft.net>
References: <200907201332.05329.remi.denis-courmont@nokia.com>
	<20090720.034328.193709571.davem@davemloft.net>
	<1248091650.4549.107.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57907
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753405AbZGTOFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:05:50 -0400
In-Reply-To: <1248091650.4549.107.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 20 Jul 2009 14:07:30 +0200

> And if we are talking about debugging information, then they should go
> into debugfs and not /proc. At least for new protocols.

Getting a list of active sockets is not, and never will be,
"debugging" information.
