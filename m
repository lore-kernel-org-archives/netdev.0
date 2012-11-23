From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: remove redundant warning log
Date: Fri, 23 Nov 2012 14:18:39 -0500 (EST)
Message-ID: <20121123.141839.1183971603333408052.davem@davemloft.net>
References: <1353604577-1272-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700Ab2KWTSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 14:18:42 -0500
In-Reply-To: <1353604577-1272-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Thu, 22 Nov 2012 19:16:17 +0200

> fix bug where a register which was only meant to be read in 578xx/57712
> devices causes a bogus error message to be logged when read from other
> devices.
> 
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
