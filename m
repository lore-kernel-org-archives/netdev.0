From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] atm/idt77252.c: make 2 functions static
Date: Mon, 31 Mar 2008 19:36:05 -0700 (PDT)
Message-ID: <20080331.193605.161051889.davem@davemloft.net>
References: <20080330231216.GA28445@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751760AbYDACgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 22:36:05 -0400
In-Reply-To: <20080330231216.GA28445@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 31 Mar 2008 02:12:16 +0300

> This patch makes the following needlessly global functions static:
> - idt77252_send()
> - idt77252_dev_close()
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied.
