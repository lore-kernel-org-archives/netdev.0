From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH linux-firmware] bnx2x: Add FW 7.13.1.0.
Date: Fri, 20 Nov 2015 11:40:30 -0500
Message-ID: <20151120164030.GF27752@merlin.infradead.org>
References: <1447951286-5896-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:59777 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760791AbbKTQkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 11:40:32 -0500
Content-Disposition: inline
In-Reply-To: <1447951286-5896-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 06:41:26PM +0200, Yuval Mintz wrote:
> This adds new FW for bnx2x, which adds the following:
>  - Ability to change outer vlan ID for some multi-function modes.
>  - FW ability for Geneve RSS classification according to inner headers.
>  - Prevent VFs from sending MAC control frames.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

applied, thanks.
