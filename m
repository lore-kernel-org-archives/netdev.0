From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: drop redundant mac address check
Date: Tue, 29 Oct 2013 10:33:13 +0100
Message-ID: <20131029103313.1f016fe2@skate>
References: <1383010161-25854-1-git-send-email-luka@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luka Perkov <luka@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:37739 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751168Ab3J2JdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 05:33:16 -0400
In-Reply-To: <1383010161-25854-1-git-send-email-luka@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Luka Perkov,

On Tue, 29 Oct 2013 02:29:21 +0100, Luka Perkov wrote:
> Checking if MAC address is valid using is_valid_ether_addr() is already done in
> of_get_mac_address().
> 
> Signed-off-by: Luka Perkov <luka@openwrt.org>

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
