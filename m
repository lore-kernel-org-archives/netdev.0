From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH linux-firmware] qed: Add FW 8.10.5.0
Date: Sun, 29 May 2016 13:17:01 -0400
Message-ID: <20160529171700.GI9173@merlin.infradead.org>
References: <1463435402-9458-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-firmware@kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:46587 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246AbcE2RRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 13:17:04 -0400
Content-Disposition: inline
In-Reply-To: <1463435402-9458-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 12:50:02AM +0300, Yuval Mintz wrote:
> The new QED firmware contains several new additions;
> As for bug-fixes, it fixes a couple of issues:
>  - Wrong classification of packets in 4-port devices.
>  - Anti-spoof interoperability with encapsulated packets.
>  - Tx-switching of encapsulated packets.
> It also slightly improves Tx performance in several scenarios.
> 
> >From the driver's feature-set POV, this firmware would
> allow us to add 2 major enhancements in the near future:
>  - It would allow us produce a register dump from the device,
>    as well as other debug-related information.
>  - It should be sufficient for our iscsi driver, which we [hopefully]
>    plan to push upstream soon.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Merged, thanks Yuval.

--Kyle
