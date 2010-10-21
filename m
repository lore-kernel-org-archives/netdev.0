From: <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net-next-2.6] be2net: Changes to use only priority codes
 allowed by f/w
Date: Thu, 21 Oct 2010 06:46:04 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F63A00DC7E9B@EXMAIL.ad.emulex.com>
References: <20101019085114.GA352@emulex.com>,<20101021.042759.52197332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:31907 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757961Ab0JUNsZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 09:48:25 -0400
In-Reply-To: <20101021.042759.52197332.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
         Looks like there was a patch applied across all drivers including be2net after i had cut the patch and sent it out .Made a fresh patch and sent it out again. 

Thanks
Som
________________________________________
From: David Miller [davem@davemloft.net]
Sent: Thursday, October 21, 2010 4:57 PM
To: Kotur, Somnath
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH net-next-2.6] be2net: Changes to use only priority codes allowed by f/w

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Tue, 19 Oct 2010 14:21:14 +0530

> Changes to use one of the priority codes allowed by CNA f/w for NIC traffic
> from host. The driver gets the bit map of the priority codes allowed for
> host traffic through a asynchronous message from the f/w that the driver
> subscribes to.
>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

This patch does not apply to the current tree.
