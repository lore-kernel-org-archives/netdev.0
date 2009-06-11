From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]vxge-config.c: no need for check
Date: Thu, 11 Jun 2009 02:51:22 -0700 (PDT)
Message-ID: <20090611.025122.75625054.davem@davemloft.net>
References: <1244643715.3422.8.camel@myhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: figo1802@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761526AbZFKJvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:51:19 -0400
In-Reply-To: <1244643715.3422.8.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Figo.zhang" <figo1802@gmail.com>
Date: Wed, 10 Jun 2009 22:21:55 +0800

> vfree() does its own 'NULL' check, so no need for check before
> calling it.
> 
> Signed-off-by: Figo.zhang <figo1802@gmail.com>

Applied.
