From: Jeff Garzik <jeff@garzik.org>
Subject: d80211: minor review item: generic_lock
Date: Thu, 10 Aug 2006 02:09:39 -0400
Message-ID: <44DACDA3.3000301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59344 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161054AbWHJGJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 02:09:41 -0400
Received: from cpe-065-190-194-075.nc.res.rr.com ([65.190.194.75] helo=[10.10.10.99])
	by mail.dvmed.net with esmtpsa (Exim 4.62 #1 (Red Hat Linux))
	id 1GB3jg-0002wu-FF
	for netdev@vger.kernel.org; Thu, 10 Aug 2006 06:09:40 +0000
To: Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

generic_lock does not appear to be used at all.
