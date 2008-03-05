From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 2/2] bluetooth: make bnep_sock_cleanup() return void
Date: Wed, 5 Mar 2008 09:51:55 +0100
Message-ID: <71422FA4-E106-4C7E-9036-2CCEB6FFF050@holtmann.org>
References: <200803042318.m24NIOc3002607@imap1.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hidave.darkstar@gmail.com,
	netdev@vger.kernel.org, linux-bluetooth@vger.kerenl.org,
	tklauser@distanz.ch
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60170 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756139AbYCEIwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 03:52:03 -0500
In-Reply-To: <200803042318.m24NIOc3002607@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> From: Tobias Klauser <tklauser@distanz.ch>
>
> bnep_sock_cleanup() always returns 0 and its return value isn't used
> anywhere in the code.
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

