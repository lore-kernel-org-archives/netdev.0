From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6][NET-2.6.24] Make netfilter code use the
 seq_open_private
Date: Wed, 10 Oct 2007 02:33:15 -0700 (PDT)
Message-ID: <20071010.023315.111208190.davem@davemloft.net>
References: <470BA351.3070208@openvz.org>
	<470BA4E9.7000909@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, kaber@trash.net
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753045AbXJJJdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:33:12 -0400
In-Reply-To: <470BA4E9.7000909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 09 Oct 2007 19:57:29 +0400

> Just switch to the consolidated calls.
> 
> ipt_recent() has to initialize the private, so use
> the __seq_open_private() helper.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Cc: Patrick McHardy <kaber@trash.net>

Applied.
