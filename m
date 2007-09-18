From: David Miller <davem@davemloft.net>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 12:21:50 -0700 (PDT)
Message-ID: <20070918.122150.124083496.davem@davemloft.net>
References: <1190141114.9540.216.camel@dell>
	<20070918.112337.74737433.davem@davemloft.net>
	<1190145951.9540.230.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vda.linux@googlemail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42492
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755028AbXIRTVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 15:21:55 -0400
In-Reply-To: <1190145951.9540.230.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 18 Sep 2007 13:05:51 -0700

> The bnx2 firmware changes quite frequently.  A new driver quite often
> requires new firmware to work correctly.  Splitting them up makes things
> difficult for the user.
> 
> The firmware in tg3 is a lot more mature and I don't expect it to
> change.  I think tg3 is better suited for using request_firmware().

Like I said, I think neither should change and the driver should
be fully functional when built statically into the kernel.

:-)
