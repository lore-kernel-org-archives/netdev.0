From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] ptp: add api to get ptp seq id and event type from
 skb
Date: Mon, 22 Oct 2012 14:37:09 +0200
Message-ID: <20121022123709.GB6151@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-5-git-send-email-mugunthanvnm@ti.com>
 <20121018025508.GD2867@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD6E6@DBDE01.ent.ti.com>
 <20121022113622.GD2285@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD904@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51935 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab2JVMhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 08:37:20 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2194524wgb.1
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 05:37:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9FD904@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 12:32:20PM +0000, N, Mugunthan V wrote:
> 
> Ok, will move this code to CPTS driver itself.

No need to fix this, since, as I already told you, I am going ahead
with my own CPTS driver.

BTW, maybe you could take a closer look at it and see what could be
improved?

Thanks,
Richard
