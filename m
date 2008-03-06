From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] bluetooth: Make hci_sock_cleanup() return void
Date: Wed, 05 Mar 2008 18:47:49 -0800 (PST)
Message-ID: <20080305.184749.159283514.davem@davemloft.net>
References: <200803042318.m24NIMum002602@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, hidave.darkstar@gmail.com,
	netdev@vger.kernel.org, linux-bluetooth@vger.kerenl.org,
	tklauser@distanz.ch
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55992
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755071AbYCFCrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 21:47:49 -0500
In-Reply-To: <200803042318.m24NIMum002602@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 04 Mar 2008 15:18:22 -0800

> From: Tobias Klauser <tklauser@distanz.ch>
> 
> hci_sock_cleanup() always returns 0 and its return value isn't used
> anywhere in the code.
> 
> Compile-tested with 'make allyesconfig && make net/bluetooth/bluetooth.ko'
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Dave Young <hidave.darkstar@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
