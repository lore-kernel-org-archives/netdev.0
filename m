From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-2.6 2009-04-19
Date: Mon, 20 Apr 2009 02:17:42 -0700 (PDT)
Message-ID: <20090420.021742.224469710.davem@davemloft.net>
References: <1240164061.11795.66.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32875
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751720AbZDTJRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:17:50 -0400
In-Reply-To: <1240164061.11795.66.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sun, 19 Apr 2009 20:01:01 +0200

> here a three more patches for the 2.6.30 kernel release. The first one
> adds a missing call to rfcomm_dlc_clear_timer. The other two are adding
> workarounds for broken Bluetooth chips/firmware from Texas Instruments
> and Broadcom. Without these two patches no audio connections can be
> successfully established.

Pulled, thanks a lot Marcel.
