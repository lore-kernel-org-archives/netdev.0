From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: Recode PCI MRRS adjustment as a PCI quirk
Date: Sun, 04 Mar 2012 20:54:15 -0500 (EST)
Message-ID: <20120304.205415.1522513082863851433.davem@davemloft.net>
References: <1330371888-29237-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab2CEByS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 20:54:18 -0500
In-Reply-To: <1330371888-29237-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 27 Feb 2012 11:44:48 -0800

> This patch recodes the MRRS cap for 5719 A0 devices as a PCI quirk.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Applied.
