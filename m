From: Patrick McHardy <kaber@trash.net>
Subject: Re: ~3 hours old git tree: Virtual device lo asks to queue packet!
Date: Thu, 19 Jul 2007 01:06:31 +0200
Message-ID: <469E9CF7.1040403@trash.net>
References: <200707182218.13548.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <arekm@maven.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50400 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbXGRXHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 19:07:09 -0400
In-Reply-To: <200707182218.13548.arekm@maven.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arkadiusz Miskiewicz wrote:
> I'm having problems with networking on recent git kernel.
> 
> kernel logs tons of "Virtual device lo asks to queue packet!"
> and networking stops working correctly:
> 
> CONFIG_NETDEVICES_MULTIQUEUE=y

Does it go away if you disable this option?
