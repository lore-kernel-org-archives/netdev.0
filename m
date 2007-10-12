From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] sky2: status polling loop
Date: Thu, 11 Oct 2007 18:23:58 -0700 (PDT)
Message-ID: <20071011.182358.21595252.davem@davemloft.net>
References: <20071012011951.575936605@linux-foundation.org>
	<20071012012124.965282742@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49608
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753939AbXJLBXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:23:55 -0400
In-Reply-To: <20071012012124.965282742@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 11 Oct 2007 18:19:52 -0700

> Handle the corner case where budget is exhausted correctly.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Doesn't apply, I checked in my fixed version of your original patch
already.

You had to have some idea I would apply that fix, so this patch series
seems a bit premature since it's almost guarenteed to not apply any
more.
