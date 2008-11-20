From: David Miller <davem@davemloft.net>
Subject: Re: macb phy address bug?
Date: Thu, 20 Nov 2008 01:04:34 -0800 (PST)
Message-ID: <20081120.010434.259572554.davem@davemloft.net>
References: <20081116.015050.238612963.davem@davemloft.net>
	<492281C9.6060006@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: giulio.benetti@micronovasrl.com, netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46434
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753275AbYKTJEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:04:34 -0500
In-Reply-To: <492281C9.6060006@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 18 Nov 2008 09:50:17 +0100

> Fix phy_id detection also for broken hardware.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> 
> --- phy_device.c.orig	2008-11-18 09:25:06.929041000 +0100
> +++ phy_device.c	2008-11-18 09:27:15.876041000 +0100

Please -p1 base your patches with the top-level kernel tree,
as described in linux/Documentation/SubmittingPatches

Please make a full resubmission, with full changelog and
signoffs, when you correct this.  Don't just resend the
fixed patch.

Thank you.
