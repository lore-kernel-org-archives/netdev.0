From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] mac802154: basic wpan class-device
 support
Date: Tue, 26 Jun 2012 21:06:58 -0700 (PDT)
Message-ID: <20120626.210658.1677892749117826235.davem@davemloft.net>
References: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab2F0EG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 00:06:58 -0400
In-Reply-To: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Tue, 26 Jun 2012 13:24:47 +0400

> Cover letter:
> =============
> this patch-set binds the IEEE 802.15.4 Linux stack to the radio
> transceivers. A new device-class called "wpan" is added. It represents
> an interface for the radio device drivers to communicate the information
> with Linux networking stack.
> 
> This is the basic support, only data-packets transmission is supported
> (no MAC-layer specific commands support included here). But this set
> represents a necessary minimum to implement IEEE 802.15.4 standard features
> and test them on real hardware.
> 
> To test/try the wpan device-class the Atmel RF230 transceiver driver
> included in this patch set. The how-to instructions are available in wiki
> at the linux-wsn project site: http://code.google.com/p/linux-wsn/

All applied, thanks.
