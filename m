From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: usbnet: update addr_assign_type if appropriate
Date: Fri, 30 Aug 2013 20:18:58 +0200
Message-ID: <87d2ovxcrx.fsf@nemi.mork.no>
References: <1377171946-19133-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oneukum@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57487 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919Ab3H3STG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:19:06 -0400
In-Reply-To: <1377171946-19133-1-git-send-email-bjorn@mork.no>
 (=?utf-8?Q?=22Bj=C3=B8rn?= Mork"'s
	message of "Thu, 22 Aug 2013 13:45:46 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> This module generates a common default address on init,
> using eth_random_addr. Set addr_assign_type to let
> userspace know the address is random unless it was
> overridden by the minidriver.
>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>

David,

I see that this patch is marked "Changes Requested" in patchworks:
http://patchwork.ozlabs.org/patch/269030/

But I haven't seen any request for changes, only Olivers ack. And that'=
s
all patchworks has recorded as well. Did I miss something?


Bj=C3=B8rn
