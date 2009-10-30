From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH against V2]NET/KS8695: add support NAPI for Rx
Date: Thu, 29 Oct 2009 23:00:02 -0700 (PDT)
Message-ID: <20091029.230002.246017938.davem@davemloft.net>
References: <1256825088.2148.77.camel@myhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsilvers@simtec.co.uk, netdev@vger.kernel.org, ben@simtec.co.uk
To: figo1802@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59888
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755257AbZJ3F7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 01:59:38 -0400
In-Reply-To: <1256825088.2148.77.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Figo.zhang" <figo1802@gmail.com>
Date: Thu, 29 Oct 2009 22:04:48 +0800

> 
> Add support NAPI Rx API for KS8695NET driver.

You're not adding NAPI support in this patch.

Instead, you're fixing up the implementation based upon feedback
you've received on this list.

Please correct your commit message and subject line and resubmit.

Thank you.
