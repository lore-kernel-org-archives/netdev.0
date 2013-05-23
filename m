From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] fec: Remove <linux/fec.h> header file
Date: Thu, 23 May 2013 00:06:07 -0700 (PDT)
Message-ID: <20130523.000607.1316970810464482365.davem@davemloft.net>
References: <1369151067-5220-1-git-send-email-fabio.estevam@freescale.com>
	<1369151067-5220-2-git-send-email-fabio.estevam@freescale.com>
	<CAOMZO5CJbfssCzHoN5EwgNac-qBgZPjWgcxR4_VWc-hBxrJ=zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, shawn.guo@linaro.org,
	netdev@vger.kernel.org, kernel@pengutronix.de
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab3EWHGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 03:06:08 -0400
In-Reply-To: <CAOMZO5CJbfssCzHoN5EwgNac-qBgZPjWgcxR4_VWc-hBxrJ=zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue, 21 May 2013 13:02:56 -0300

> On Tue, May 21, 2013 at 12:44 PM, Fabio Estevam
> <fabio.estevam@freescale.com> wrote:
>> There is no need to have a header file to hold a single structure.
>>
>> Move the 'fec_platform_data' structure definition into the local "fec.h" file
>> and get rid of <linux/fec.h> header.
> 
> Please discard this one. It will cause issues on Coldfire.

Ok.
