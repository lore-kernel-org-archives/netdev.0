From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] move sgiseeq's probe function to .devinit.text
Date: Tue, 21 Jul 2009 20:13:25 -0700 (PDT)
Message-ID: <20090721.201325.44441001.davem@davemloft.net>
References: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<1248211527-32253-5-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangchen@cn.fujitsu.com,
	akpm@linux-foundation.org, jgarzik@redhat.com,
	tsbogend@alpha.franken.de, gregkh@suse.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50444
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756098AbZGVDNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 23:13:19 -0400
In-Reply-To: <1248211527-32253-5-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Applied.
