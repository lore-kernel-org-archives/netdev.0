From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net 2/4] lan78xx: replace devid to chipid & chiprev
Date: Mon, 25 Jan 2016 23:35:43 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4049DF42@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D4049DED4@CHN-SV-EXMX02.mchp-main.com>
 <20160125.152729.132746793740931912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:60983 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932384AbcAYXfo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 18:35:44 -0500
In-Reply-To: <20160125.152729.132746793740931912.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Such cleanups are not appropriate for the 'net' tree.
> 
> And the 'net-next' tree is closed.
> 
> You _MUST_ separate out the pure bug fixes and submit only those
> changes targetting the 'net' tree.
> 
> You must learn how to submit changes properly.

Thanks for pointing out. Will resubmit after modification.
And, will post this cleanup to net-next when it opens.
