From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 5/6] drivers: net: ethernet: cpts: implement cpts
 hardware clock
Date: Mon, 22 Oct 2012 13:44:35 +0200
Message-ID: <20121022114435.GF2285@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-6-git-send-email-mugunthanvnm@ti.com>
 <20121020134331.GA5444@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD709@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:45405 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab2JVLop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 07:44:45 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so2362964wib.1
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 04:44:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9FD709@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 10:55:55AM +0000, N, Mugunthan V wrote:
> 
> The CPTS found in DM81XX and AM335X is of same version, only the CPSW version
> is different in both SoCs.

Actually, the CPTS appears to be different between DM81XX and AM335X.

The DM81XX has a CPTS_RFTCLK_SEL which is not found in the AM335X.

Thanks,
Richard
