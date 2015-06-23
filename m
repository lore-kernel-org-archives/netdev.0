From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] debugfs for mv88e6xxx
Date: Tue, 23 Jun 2015 06:34:41 -0700 (PDT)
Message-ID: <20150623.063441.986480329560181318.davem@davemloft.net>
References: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, cory.tusar@pid1solutions.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371AbbFWNWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:22:52 -0400
In-Reply-To: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat, 20 Jun 2015 18:42:27 +0200

> This patchset adds some debugfs files for seeing into a mv88e6xxx
> family of switch chips.

Series applied, thanks.

Although, long term, I'm very disappointed that we can't extend
ethtool to demux on the DSA ports via some new key or similar
facility.
