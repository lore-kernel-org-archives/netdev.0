From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [RFC] qlge: New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Fri, 22 Aug 2008 13:09:06 -0700
Message-ID: <20080822200906.GD2551@susedev.qlogic.org>
References: <20080821185402.GD31526@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: jeff@garzik.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37924 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbYHVUJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 16:09:41 -0400
Content-Disposition: inline
In-Reply-To: <20080821185402.GD31526@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff/Ben,

Attached is our new 10Gb driver as a patch series per our discussion.

I moved the ethtool functionality into a separate modules as it will grow
with reg dump etc...


We are targeting this driver for 2.6.28 release.  We look forward to any and all comments.
Notes:
 
Regards,
Ron Mercer
Qlogic Corporation
