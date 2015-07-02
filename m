From: Stephen Hemminger <stephen@networkplumber.org>
Subject: iproute 4.1.1
Date: Wed, 1 Jul 2015 18:28:44 -1000
Message-ID: <20150701182844.05fb7742@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34545 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbbGBE2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 00:28:53 -0400
Received: by pabvl15 with SMTP id vl15so33744787pab.1
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 21:28:53 -0700 (PDT)
Received: from uryu.home.lan (cpe-72-130-168-110.hawaii.res.rr.com. [72.130.168.110])
        by mx.google.com with ESMTPSA id de4sm3911933pbb.95.2015.07.01.21.28.51
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 21:28:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am putting out iproute2 4.1.1 (ie stable) on Monday. Will include fixes for MPLS and TIPC that
are already in latest (master). Is there any other fixes which people think are urgent enough to
backport.
