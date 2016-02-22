From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/3] Patchset for gianfar ptp driver
Date: Mon, 22 Feb 2016 09:32:41 +0100
Message-ID: <20160222083241.GA2138@netboy>
References: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38839 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbcBVIcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 03:32:45 -0500
Received: by mail-wm0-f47.google.com with SMTP id a4so151220636wme.1
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 00:32:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2016 at 02:49:30PM +0800, Yangbo Lu wrote:
> This patchset is to enable ptp support for ls1021a platform. The endianness
> issue in gianfar driver and gianfar ptp driver must be fixed, and a 1588
> timer node must be added into dts.

Why have you excluded both the driver author and the PTP maintainer
from CC?

Thanks,
Richard
