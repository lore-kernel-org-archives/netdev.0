From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Latest fixes to bcm43xx-d80211 now available as patch to 2.6.18
Date: Thu, 05 Oct 2006 18:33:45 -0500
Message-ID: <45259659.9040804@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:12210 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932429AbWJEXdu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 19:33:50 -0400
To: Bcm43xx-dev@lists.berlios.de, netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The latest set of changes/fixes for bcm43xx-d80211 are now available as a patch to v2.6.18 code from 
ftp://lwfinger.dynalias.org/.

The patch file contains Michael Buesch's changes of 05-Oct-2006. This version can use either V3 or 
V4 firmware. It has been compiled and tested on my system.

The above site is maintained so that users of bcm43xx can test the latest version of the drivers for 
either wireless-2.6 or wireless-dev without having to employ git, or download the entire git tree. 
Either patch file is designed to apply to the latest vanilla source of the stable version that is 
downloaded from http://www.kernel.org.

Larry
