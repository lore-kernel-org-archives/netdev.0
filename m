From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: compile fix for removal of byteorder wrapper
Date: Thu, 27 Nov 2008 23:04:23 -0800 (PST)
Message-ID: <20081127.230423.185132606.davem@davemloft.net>
References: <1227836478.5477.2.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ioe-lkml@rameria.de, swhiteho@redhat.com, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60207
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751340AbYK1HEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 02:04:23 -0500
In-Reply-To: <1227836478.5477.2.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 27 Nov 2008 17:41:18 -0800

> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> Sorry Dave, I actually had a dirty working tree with an extra
> copy of unaligned.h as unalignedh so it compiled here.

Applied.
