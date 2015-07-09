From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] Ignore commands and config which is not fit on
 8101/8102 chip
Date: Thu, 09 Jul 2015 01:29:58 -0700 (PDT)
Message-ID: <20150709.012958.1561564703927025957.davem@davemloft.net>
References: <CAGg4U=HTksdudMviWnirnW2O_RxMSZxWEkqKcErsUySoR+0tmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbbGIIaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 04:30:03 -0400
In-Reply-To: <CAGg4U=HTksdudMviWnirnW2O_RxMSZxWEkqKcErsUySoR+0tmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


None of these r8169 patch submissions are being submitted properly.

First, please do not use attachments.

Only provide exactly your commit message, full signoff, and the patch
in plain ASCII text, in the body of your message.

Also, please format your Subject line properly.  It should be of the
form "[PATCH net-next] $SUBSYSTEM: $DESCRIPTION"

Where $SUBSYSTEM here should be "r8169: "

Basically, you should look carefully and in detail how other developers
sucessfully post patches to the netdev list and mimick them as closely
as possible.
