From: Michael Buesch <mb@bu3sch.de>
Subject: Can someone please try...
Date: Tue, 16 Jan 2007 18:06:02 +0100
Message-ID: <200701161806.02780.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39761
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbXAPRIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 12:08:05 -0500
To: bcm43xx-dev@lists.berlios.de
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

...the bcm43xx driver in my tree with a 4318 chip?
The code there works excellent with my 4306 now, but I can't
get it to work with my 4318. It's strange, it doesn't seem
to work at all. I don't seem to be able to TX and RX any packet.
Not sure why.

To get it, please try to avoid cloning the whole tree
from my repository to avoid unnecessary bandwidth wasting.
If you have a linville-wireless-dev tree, you can do the
following:

cd wireless-dev
git branch mb
git checkout mb
git pull http://bu3sch.de/git/wireless-dev.git master

I think this should also work if you have a linus-2.6 tree
checked out somewhere.

-- 
Greetings Michael.
