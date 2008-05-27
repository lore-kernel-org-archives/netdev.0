From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 8/8] tg3: Update version to 3.93
Date: Tue, 27 May 2008 10:58:08 -0700
Message-ID: <20080527175808.GA31979@localdomain>
References: <1211511433.0@teletran1>
 <20080525.235115.264290985.davem@davemloft.net>
 <20080525.235311.235732094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com,
	benli@broadcom.com, andy@greyhouse.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2591 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755741AbYE0Rye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 13:54:34 -0400
In-Reply-To: <20080525.235311.235732094.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 25, 2008 at 11:53:11PM -0700, David Miller wrote:
> 
> Matt, don't we need a PHYLIB dependency or select statement for the
> tg3 driver option in drivers/net/Kconfig now?

Indeed, you are correct.  I'll submit a follow-on patch in another
email.


