From: Peter Daum <gator_ml@yahoo.de>
Subject: What is the "ll header" of a PPP Interface?
Date: Mon, 05 Oct 2009 11:30:20 +0200
Message-ID: <haceb8$c39$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:55139 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932554AbZJEKum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 06:50:42 -0400
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1Mul8m-00010z-DV
	for netdev@vger.kernel.org; Mon, 05 Oct 2009 12:50:04 +0200
Received: from p57a0cff9.dip.t-dialin.net ([87.160.207.249])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2009 12:50:04 +0200
Received: from gator_ml by p57a0cff9.dip.t-dialin.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2009 12:50:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I occasionally get syslog messages about "martians" coming in on a PPP interface.
Normally, the reported ll header is the 2 involved MAC addresses and the ethernet
frame type. For the PPP interface however, the reported ll header is 22 bytes long
and I can't find any information about the significance of it.

Can somebody here maybe enlighten me?

Regards,
                         Peter

