From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 5/6] drivers: net: ethernet: cpts: implement cpts
 hardware clock
Date: Mon, 22 Oct 2012 13:41:03 +0200
Message-ID: <20121022114103.GE2285@netboy.at.omicron.at>
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
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36418 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab2JVLlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 07:41:13 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so2359553wib.1
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 04:41:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9FD709@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 10:55:55AM +0000, N, Mugunthan V wrote:
> > - I will add a version check for CPTS v2 and integrate your CPSW
> >   multicast patch (and anything else you think is missing) into my own
> >   patch series. Once your background patches have appeared, I will
> >   post the CPTS series for net-next, in time for v3.8.
> 
> The CPTS found in DM81XX and AM335X is of same version, only the CPSW version
> is different in both SoCs.

Okay, good, so we can keep the differences within the CPSW driver.

Thanks,
Richard
