From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: VIA Velocity 6130 - is it supported?
Date: Fri, 10 Sep 2010 00:07:51 +0200
Message-ID: <20100909220751.GA10652@electric-eye.fr.zoreil.com>
References: <4C87EB8A.6050503@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew <nitr0@seti.kr.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 217.59.140-88.rev.gaoland.net ([88.140.59.217]:55985 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751682Ab0IIWIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 18:08:15 -0400
Content-Disposition: inline
In-Reply-To: <4C87EB8A.6050503@seti.kr.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew <nitr0@seti.kr.ua> :
[...]
> I tried to run VT6130 on 2.6.35.2 kernel - but as result I have eth
> device with MAC ff:ff:ff:ff:ff:ff, that can't be upped - RNETLINK
> returns a lot of errors 'can't set address".

All '1' registers.

No missing acpi nor hidden power management option ?

> Is this device supported by kernel drivers?

No positive evidence but Via's driver does not handle this
chipset differently.

-- 
Ueimor
