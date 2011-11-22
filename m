From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH 1/1]   PHY configuration for compatible issue
Date: Wed, 23 Nov 2011 00:19:59 +0800
Message-ID: <20111122161924.M90675@cooldavid.org>
References: <1321906842-1476-1-git-send-email-AriesLee@jmicron.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
To: AriesLee <AriesLee@jmicron.com>,
	Aries Lee <ariesleeILan@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:33152 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757780Ab1KVQUL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Nov 2011 11:20:11 -0500
In-Reply-To: <1321906842-1476-1-git-send-email-AriesLee@jmicron.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2011 04:20:42 +0800, AriesLee wrote
> To perform PHY calibration and set a different EA value by chip ID,
> Whenever the NIC chip power on, ie booting or resuming, we need to
> force HW to calibrate PHY parameter again, and also set a proper EA
> value which gather from experiment.
> 
> Those procedures help to reduce compatible issues(NIC is unable to link
> up in some special case) in giga speed.
> 
> Signed-off-by: AriesLee <AriesLee@jmicron.com>
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Guo-Fu Tseng
