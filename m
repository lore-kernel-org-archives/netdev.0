From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] drivers/net/ipg.c: cleanups
Date: Thu, 25 Oct 2007 03:31:35 -0400
Message-ID: <47204657.3080701@pobox.com>
References: <20071024162319.GL30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Huang <jesse@icplus.com.tw>,
	Stefan Lippers-Hollmann <s.l-h@gmx.de>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58938 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757714AbXJYHbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 03:31:51 -0400
In-Reply-To: <20071024162319.GL30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch contains the following cleanups:
> - make ipg_nic_get_stats() static
> - move DefaultPhyParam[] from ipg.h to ipg.c and make it static
> 

applied


