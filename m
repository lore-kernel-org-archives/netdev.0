From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] ethtool always report port is TP on tg3
Date: Fri, 12 May 2006 07:59:54 -0700
Message-ID: <1147445994.4780.55.camel@rh4>
References: <20060512100541.GA10529@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Andrew Morton" <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:8460 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S932148AbWELQjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 12:39:45 -0400
To: "Karsten Keil" <kkeil@suse.de>
In-Reply-To: <20060512100541.GA10529@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-05-12 at 12:05 +0200, Karsten Keil wrote:
> Even with fiber cards ethtool reports that the connected port is TP,
> the patch fix this.

ACK. Thanks. Please add sign-off line and send to DaveM.


