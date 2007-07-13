From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PATCH 2.6.22 3/4]S2IO: Removing 3 buffer mode support from the driver
Date: Sat, 14 Jul 2007 00:23:21 +0200
Message-ID: <20070713222321.GD18669@electric-eye.fr.zoreil.com>
References: <Pine.GSO.4.10.10707120618420.16507-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: Veena Parat <Veena.Parat@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33496 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752074AbXGMWZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 18:25:05 -0400
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.10.10707120618420.16507-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Veena Parat <Veena.Parat@neterion.com> :
>  - Removed 3 buffer mode support from driver - unused feature

Please make it the first patch in the serie.

It will avoid modifying fill_rxd_3buf() needlessly in the previous patches.

-- 
Ueimor
