From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: Add "phy-reset-active-low" property to DT
Date: Wed, 2 Mar 2016 17:08:49 -0300
Message-ID: <CAOMZO5ANea=E2C+o-F5RxaX=LNg6hYiBCLJkaFwz4qp9qpjJTg@mail.gmail.com>
References: <56D5CE66.3010602@boundarydevices.com>
	<20160302200540.GA10722@euler.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>
To: Bernhard Walle <bernhard@bwalle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36577 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478AbcCBUIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 15:08:50 -0500
Received: by mail-io0-f181.google.com with SMTP id l127so4094812iof.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 12:08:49 -0800 (PST)
In-Reply-To: <20160302200540.GA10722@euler.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 2, 2016 at 5:05 PM, Bernhard Walle <bernhard@bwalle.de> wrote:

> Indeed, you're correct.
>
> Should I send a new patch or a patch that corrects my first patch?
> Because it already is in linux-next.

As your patch is already in linux-next you should send an incremental
patch then. Thanks
