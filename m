From: Janek Kozicki <janek_listy@wp.pl>
Subject: Belkin F5U258 Host to Host cable (usbnet, plusb) - that patch
 works.
Date: Fri, 7 Nov 2008 18:37:37 +0100
Message-ID: <20081107183737.34f66e98@szpak>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.wp.pl ([212.77.101.5]:57105 "EHLO mx1.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbYKGRht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 12:37:49 -0500
Received: from a3gw.hmg.inpg.fr (HELO szpak) (janek_listy@[194.254.65.43])
          (envelope-sender <janek_listy@wp.pl>)
          by smtp.wp.pl (WP-SMTPD) with SMTP
          for <netdev@vger.kernel.org>; 7 Nov 2008 18:37:41 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I bought this new Belkin "Vista" (bleh) host to host USB network
cable. It uses F5U258 chipset. And it works with that patch (posted
on this mailing list on 16 Feb 2008):

  http://article.gmane.org/gmane.linux.network/86240

I just wanted to let you know that this patch works well, and it
would be kind-of useful if it was applied to linux source.

Currently I will need to apply this patch every time when I upgrade
my kernel, which is kind of painful because I got used to debian
prebuilt linux-image packages :)


I didn't subscribe to this mailing list (sorry for that) because I just
wanted to let you know that this patch works and nothing more. If
this post creates some additional discussion I'll watch it through
online archive (or you could CC me if that's not too cumbersome for you ;)

-- 
Janek Kozicki                                                         |
