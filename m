From: Roland Dreier <rdreier@cisco.com>
Subject: Re: New Qlogic qla3xxx NIC Driver v2.02.00k34 for upstream inclusion
Date: Thu, 22 Jun 2006 17:05:22 -0700
Message-ID: <adapsh0losd.fsf@cisco.com>
References: <0BB3E5E7462EEA4295BC02D49691DC0717688F@AVEXCH1.qlogic.org>
	<449B2621.7080607@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ron Mercer <ron.mercer@qlogic.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-driver@qlogic.com,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:34315 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S1750779AbWFWAF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 20:05:26 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <449B2621.7080607@garzik.org> (Jeff Garzik's message of "Thu, 22 Jun 2006 19:22:09 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > 15) I wonder if SA_SHIRQ needs to be set, for MSI?

Why would it?  MSI vectors are always unique, aren't they?

 - R.
