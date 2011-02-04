From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Submitting new device driver
Date: Fri, 4 Feb 2011 11:53:58 +0100
Message-ID: <20110204105358.GA9259@electric-eye.fr.zoreil.com>
References: <4D4B6CEA.5060900@users.sf.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nik Trevallyn-Jones <nik777@users.sf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49056 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab1BDK42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 05:56:28 -0500
Content-Disposition: inline
In-Reply-To: <4D4B6CEA.5060900@users.sf.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nik Trevallyn-Jones <nik777@users.sf.net> :
[...]
> To that end, I've been reading the various documents on requirements
> for submitting a driver, and am now trying to contact the
> appropriate maintainers.

Greg Kroah-Hartman <gregkh@suse.de> for both staging and usb.

linux-wireless@vger.kernel.org eventually.

[...]
> I have recently made changes to support the 2.6.36 kernel, and will
> shortly review all the code to ensure compliance with the various
> guidelines regarding mainline drivers.

Please use netdev_priv too.

> Could you please either let me know who I should direct my
> request/submission to, or point me to the appropriate document that
> tells me?

See MAINTAINERS file at the top of the kernel tree.

-- 
Ueimor
