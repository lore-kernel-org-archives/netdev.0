From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use inline function dst_metric() instead of direct
 access to dst->metric[]
Date: Sat, 26 Apr 2008 23:23:32 -0700 (PDT)
Message-ID: <20080426.232332.30254129.davem@davemloft.net>
References: <d72b7ace0804250717g40f81ea0o899f43fdc1d08384@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: satoru.satoh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60553
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751010AbYD0GXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 02:23:35 -0400
In-Reply-To: <d72b7ace0804250717g40f81ea0o899f43fdc1d08384@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Satoru SATOH" <satoru.satoh@gmail.com>
Date: Fri, 25 Apr 2008 23:17:00 +0900

> There are functions to refer to the value of dst->metric[THE_METRIC-1] directly
> without use of a inline function "dst_metric" defined in net/dst.h.
> 
> The following patch changes them to use the inline function consistently.
> 
> Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

Your email client has corrupted the patch, adding line breaks and
making other transformations that make the patch not apply cleanly.

Please correct this and resubmit your patch.

Thank you!
