From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] EEE support for mv88e6172
Date: Wed, 11 Mar 2015 16:59:31 -0400 (EDT)
Message-ID: <20150311.165931.2141833376642325076.davem@davemloft.net>
References: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbbCKU7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:59:33 -0400
In-Reply-To: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 10 Mar 2015 23:05:56 +0100

> This patchset contains two cleanups and then adds EEE support
> to the mv88e6172, using the base provided by Guenter Roeck
> 
> Tested on a WRT1900AC with mv88e6172 and DIR665 with mv88e6171.

This series does not apply cleanly to net-next.

I really want to discourage you posting patches against trees other
that net and net-next like this, without CLEARLY marking in the
Subject lines that this patch series is special and that I should
not try to review and apply it at all.
