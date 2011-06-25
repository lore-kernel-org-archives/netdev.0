From: David Dillow <dave@thedillows.org>
Subject: Re: [RFC 02/72] 3c*/acenic/typhoon: Move 3Com Ethernet drivers
Date: Sat, 25 Jun 2011 12:11:58 -0400
Message-ID: <1309018318.6908.1.camel@obelisk.thedillows.org>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrix.voodoobox.net ([75.127.97.206]:33253 "EHLO
	matrix.voodoobox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab1FYQME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 12:12:04 -0400
In-Reply-To: <1309010363-22750-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-06-25 at 06:58 -0700, Jeff Kirsher wrote:
> Moves the 3Com drivers into drivers/net/ethernet/3com/ and the necessary
> Kconfig and Makefile changes.

> CC: David Dillow <dave@thedillows.org>

>  drivers/net/{ => ethernet/3com}/typhoon.c        |    0
>  drivers/net/{ => ethernet/3com}/typhoon.h        |    0

For what it's worth:

Acked-by: David Dillow <dave@thedillows.org>

