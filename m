From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]netxen: fix checking
Date: Thu, 11 Jun 2009 02:51:11 -0700 (PDT)
Message-ID: <20090611.025111.100321664.davem@davemloft.net>
References: <1244643227.3422.3.camel@myhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay@netxen.com
To: figo1802@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35550
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758332AbZFKJvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:51:08 -0400
In-Reply-To: <1244643227.3422.3.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Figo.zhang" <figo1802@gmail.com>
Date: Wed, 10 Jun 2009 22:13:47 +0800

> vfree() does its own 'NULL' check, so no need for check before
> calling it.
> 
> Signed-off-by: Figo.zhang <figo1802@gmail.com>

Applied.
