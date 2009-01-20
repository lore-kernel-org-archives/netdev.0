From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: [PATCH] phy: Add suspend/resume support to SMSC PHYs
Date: Tue, 20 Jan 2009 16:05:43 -0600
Message-ID: <2acbd3e40901201405o102573fwdfdfe05b40b9c206@mail.gmail.com>
References: <1232459038-13156-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>,
	"Ian Saturley" <ian.saturley@smsc.com>
To: "Steve Glendinning" <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:15018 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbZATWFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 17:05:44 -0500
Received: by wf-out-1314.google.com with SMTP id 27so4000044wfd.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 14:05:43 -0800 (PST)
In-Reply-To: <1232459038-13156-1-git-send-email-steve.glendinning@smsc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2009 at 7:43 AM, Steve Glendinning
<steve.glendinning@smsc.com> wrote:
> All supported SMSC PHYs implement the standard "power down" bit 11 of
> BMCR, so this patch adds support using the generic genphy_{suspend,resume}
> functions.
>
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
Acked-by: Andy Fleming <afleming@freescale.com>
