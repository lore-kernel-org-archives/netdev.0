From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre: allow changing mac address when device
 is up
Date: Tue, 10 Jun 2014 22:46:55 -0700 (PDT)
Message-ID: <20140610.224655.1504125667179693310.davem@davemloft.net>
References: <20140606081000.5029a6f0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673AbaFKFq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 01:46:56 -0400
In-Reply-To: <20140606081000.5029a6f0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 6 Jun 2014 08:10:00 -0700

> There is no need to require forcing device down on a Ethernet GRE (gretap)
> tunnel to change the MAC address.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
