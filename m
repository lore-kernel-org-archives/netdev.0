From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] switchdev: enforce no pvid flag in vlan ranges
Date: Mon, 12 Oct 2015 14:17:16 +0200
Message-ID: <20151012121715.GD2370@nanopsycho.orion>
References: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
 <1444651299-2813-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33809 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbbJLMRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 08:17:23 -0400
Received: by wicgb1 with SMTP id gb1so48000836wic.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 05:17:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1444651299-2813-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 12, 2015 at 02:01:39PM CEST, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>We shouldn't allow BRIDGE_VLAN_INFO_PVID flag in VLAN ranges.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
