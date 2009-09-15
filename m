From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: smc91x: drop Blackfin cruft
Date: Mon, 14 Sep 2009 17:07:26 -0700 (PDT)
Message-ID: <20090914.170726.40013045.davem@davemloft.net>
References: <1252951422-11543-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michael.hennerich@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58880
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752090AbZIOAHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 20:07:10 -0400
In-Reply-To: <1252951422-11543-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 14 Sep 2009 14:03:42 -0400

> From: Michael Hennerich <michael.hennerich@analog.com>
> 
> Now that all Blackfin boards are using the board resources, we don't need
> to keep the arch/board specific crap in the driver header.
> 
> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
