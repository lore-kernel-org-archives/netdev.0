From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: RE: [PATCH 0/3] Patchset for gianfar ptp driver
Date: Wed, 24 Feb 2016 09:21:36 +0000
Message-ID: <HE1PR04MB08893E3B85F1B30361FC7677F8A50@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
 <20160222083241.GA2138@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0071.outbound.protection.outlook.com ([157.55.234.71]:20480
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751270AbcBXJgP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 04:36:15 -0500
In-Reply-To: <20160222083241.GA2138@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, February 22, 2016 4:33 PM
> To: Yangbo Lu
> Cc: netdev@vger.kernel.org; Claudiu Manoil
> Subject: Re: [PATCH 0/3] Patchset for gianfar ptp driver
> 
> On Mon, Feb 22, 2016 at 02:49:30PM +0800, Yangbo Lu wrote:
> > This patchset is to enable ptp support for ls1021a platform. The
> > endianness issue in gianfar driver and gianfar ptp driver must be
> > fixed, and a 1588 timer node must be added into dts.
> 
> Why have you excluded both the driver author and the PTP maintainer from
> CC?
>
 
[Lu Yangbo-B47093] Sorry for missing some reviewers. I will add them in the later v2 patchset.
Thanks a lot, Richard.

> Thanks,
> Richard
