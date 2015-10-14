From: Oliver Neukum <oneukum@suse.com>
Subject: Killing USBNET as an independent Konfig option
Date: Wed, 14 Oct 2015 12:45:31 +0200
Message-ID: <1444819531.1975.2.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40354 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbbJNKrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 06:47:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

would anybody mind me killing the separate config option
of usbnet? I can see no sense in having it as a separate
option, as it is just infrastructure.

	Regards
		Oliver
