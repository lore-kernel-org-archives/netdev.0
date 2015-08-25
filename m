From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH 1/3] drivers: net: cpsw: add am335x errata workarround
 for interrutps
Date: Tue, 25 Aug 2015 11:47:33 +0530
Message-ID: <55DC087D.4090604@ti.com>
References: <1439373175-8650-1-git-send-email-mugunthanvnm@ti.com> <1439373175-8650-2-git-send-email-mugunthanvnm@ti.com> <55DAEC28.3030107@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, <alex.aring@gmail.com>
To: Sekhar Nori <nsekhar@ti.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:42440 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825AbbHYGRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 02:17:42 -0400
In-Reply-To: <55DAEC28.3030107@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 24 August 2015 03:34 PM, Sekhar Nori wrote:
> Hi Mugunthan,
> 
> On Wednesday 12 August 2015 03:22 PM, Mugunthan V N wrote:
>> > +static const struct of_device_id cpsw_of_mtable[] = {
>> > +	{ .compatible = "ti,cpsw", .data = &cpsw_devtype[CPSW], },
>> > +	{ .compatible = "ti,am335x-cpsw", .data = &cpsw_devtype[AM335X_CPSW], },
>> > +	{ .compatible = "ti,am4372-cpsw", .data = &cpsw_devtype[AM4372_CPSW], },
>> > +	{ .compatible = "ti,dra7-cpsw", .data = &cpsw_devtype[DRA7_CPSW], },
> I do not see documentation added for these compatibles. Since the series
> is already applied, can you send additional patches adding documentation?

Will submit a patch ASAP

Regards
Mugunthan V N
