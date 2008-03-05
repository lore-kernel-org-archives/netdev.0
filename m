From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 1/2] bluetooth: Make hci_sock_cleanup() return void
Date: Wed, 5 Mar 2008 09:50:39 +0100
Message-ID: <18E10430-F742-4D48-9937-2469833C18CF@holtmann.org>
References: <200803042318.m24NIMum002602@imap1.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hidave.darkstar@gmail.com,
	netdev@vger.kernel.org, linux-bluetooth@vger.kerenl.org,
	tklauser@distanz.ch
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60165 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759919AbYCEIus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 03:50:48 -0500
In-Reply-To: <200803042318.m24NIMum002602@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> From: Tobias Klauser <tklauser@distanz.ch>
>
> hci_sock_cleanup() always returns 0 and its return value isn't used
> anywhere in the code.
>
> Compile-tested with 'make allyesconfig && make net/bluetooth/ 
> bluetooth.ko'
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Dave Young <hidave.darkstar@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Dave, I can queue these up if you don't wanna grab them into netdev  
tree by yourself.

Regards

Marcel

