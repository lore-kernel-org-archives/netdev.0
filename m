From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Tue, 30 Jun 2009 17:50:16 +0300
Message-ID: <1246373417.1685.3.camel@lb-tlvb-eilong>
References: <4A41961B.2090206@miraclelinux.com>
 <4A4257B8.2090105@hp.com>
 <1245862760.12000.507.camel@nseg_linux_HP1.broadcom.com>
 <4A480FA8.4000401@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Rick Jones" <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Naohiro Ooiwa" <nooiwa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3480 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbZF3Ouo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2009 10:50:44 -0400
In-Reply-To: <4A480FA8.4000401@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-06-28 at 17:49 -0700, Naohiro Ooiwa wrote:
> Hi Michael
> 
> Thank you for your comment.
> 
> I tried to create a patch of bnx2x driver.
> It's the same fix as bnx2 driver.
> Could you please check the my patch ?
> 
> Of cource, I made sure of compile.

It is also working as expected. I already made a similar patch based on
your bnx2 fix and it looks exactly the same...

Thanks!

> 
> Signed-off-by: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>


