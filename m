From: =?utf-8?B?RnJhbsOnb2lz?= Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 doesn't report link state correctly.
Date: Wed, 13 Apr 2011 19:48:15 +0200
Message-ID: <20110413174815.GB17579@electric-eye.fr.zoreil.com>
References: <4DA35FEF.1030009@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57174 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206Ab1DMRzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 13:55:50 -0400
Content-Disposition: inline
In-Reply-To: <4DA35FEF.1030009@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2011 at 01:09:19PM -0700, Ben Greear wrote:
> I notice that in kernel 2.6.38-wl, the realtek 8169 NIC doesn't
> report link down when in fact there is no cable connected.  Instead,
> it shows 10Mbps half-duplex.  I have no idea if this previously worked
> or not.

Thanks for the report. I'll try it tomorrow or friday.

-- 
Ueimor
