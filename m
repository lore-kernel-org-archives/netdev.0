From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 02/07] r8169: Support for byte queue limits
Date: Tue, 15 Oct 2013 00:28:38 +0200
Message-ID: <20131014222838.GA4061@electric-eye.fr.zoreil.com>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
 <1381775183-24866-3-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Igor Maravic <igorm@etf.rs>
To: Tino Reichardt <milky-kernel@mcmilk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56340 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757517Ab3JNW2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 18:28:50 -0400
Content-Disposition: inline
In-Reply-To: <1381775183-24866-3-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tino Reichardt <milky-kernel@mcmilk.de> :
[...]
> I have tested this patch on a small server in home use and it's working with
> no problems for about two weeks now. (kernel 3.10.10 and fq_codel enabled)
> 
> Original-Patch-By: Igor Maravic <igorm@etf.rs>
> Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

It seems fine. Please include 'net-next' in the Subject field.

-- 
Ueimor
