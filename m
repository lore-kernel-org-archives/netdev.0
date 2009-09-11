From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ucc_geth: Rearrange some code to avoid forward
 declarations
Date: Fri, 11 Sep 2009 12:19:50 -0700 (PDT)
Message-ID: <20090911.121950.207367910.davem@davemloft.net>
References: <20090910020140.GB31083@oksana.dev.rtsoft.ru>
	<4AA8F880.1000300@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, afleming@freescale.com,
	leoli@freescale.com, galak@kernel.crashing.org,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39463
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753786AbZIKTTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:19:34 -0400
In-Reply-To: <4AA8F880.1000300@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Thu, 10 Sep 2009 08:00:48 -0500

> Anton Vorontsov wrote:
>> We'll need ugeth_disable() and ugeth_enable() calls earlier in the
>> file, so rearrange some code to avoid forward declarations.
>> 
>> The patch doesn't contain any functional changes.
>> 
>> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> 
> Acked-by: Timur Tabi <timur@freescale.com>

Applied.
