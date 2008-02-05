From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/7] bluetooth: blacklist another Broadcom BCM2035
 device
Date: Tue, 05 Feb 2008 03:10:25 -0800 (PST)
Message-ID: <20080205.031025.171453745.davem@davemloft.net>
References: <200802050747.m157lwwg010458@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@vger.kernel.org, andy@smile.org.ua
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756583AbYBELJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:09:57 -0500
In-Reply-To: <200802050747.m157lwwg010458@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 04 Feb 2008 23:48:17 -0800

> From: Andy Shevchenko <andy@smile.org.ua>
> 
> This device is recognized as bluetooth, but still not works.
> 
> Signed-off-by: Andy Shevchenko <andy@smile.org.ua>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.

But, what driver should drive this device?
