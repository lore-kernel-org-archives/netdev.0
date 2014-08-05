From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2 1/2] net: phy: Set the driver when registering an MDIO
 bus device
Date: Tue, 5 Aug 2014 08:02:13 -0300
Message-ID: <CAOMZO5CMC9aKRBBV62D7gaPwuCEf-CHNKcC9m3TMeLS4xR1Xqw@mail.gmail.com>
References: <1406144852-7379-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1406144852-7379-2-git-send-email-ezequiel.garcia@free-electrons.com>
	<CAOMZO5CH0VystNR+qpXQFB_1f9=0DZzm7xxD5Fxy+uxFmAa-0Q@mail.gmail.com>
	<20140805032257.GD2167@dragon>
	<53E05702.9000007@gmail.com>
	<20140805044137.GE2167@dragon>
	<20140805104332.GA2704@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shawn Guo <shawn.guo@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	=?UTF-8?B?TWFyZWsgVmHFoXV0?= <marex@denx.de>,
	Sascha Hauer <kernel@pengutronix.de>,
	Russell King <linux@arm.linux.org.uk>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:39163 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343AbaHELCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 07:02:15 -0400
Received: by mail-la0-f54.google.com with SMTP id hz20so562089lab.41
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 04:02:13 -0700 (PDT)
In-Reply-To: <20140805104332.GA2704@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 5, 2014 at 7:43 AM, Ezequiel Garcia
<ezequiel.garcia@free-electrons.com> wrote:

> Indeed, this commit should be reverted.

Ok, will send a patch reverting it.

Thanks
