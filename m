From: David Miller <davem@davemloft.net>
Subject: Re: [patch] tokenring: remove unneeded NULL checks
Date: Sun, 22 Aug 2010 00:54:40 -0700 (PDT)
Message-ID: <20100822.005440.246513406.davem@davemloft.net>
References: <20100819100438.GC6674@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43432
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751286Ab0HVIB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 04:01:59 -0400
In-Reply-To: <20100819100438.GC6674@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 19 Aug 2010 12:04:38 +0200

> "fw_entry" is always non-NULL at this point and anyway
> release_firmware() handles NULL parameters.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
