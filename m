From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Small improvements for the at803x PHY driver
Date: Sat, 26 Dec 2015 01:26:58 +0100
Message-ID: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
Cc: f.fainelli@gmail.com, slash.tmp@free.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36341 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbbLZA1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2015 19:27:37 -0500
Received: by mail-wm0-f46.google.com with SMTP id p187so211306588wmp.1
        for <netdev@vger.kernel.org>; Fri, 25 Dec 2015 16:27:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

while trying to debug a problem on a board with an AR8030 PHY (which turned
out to be an incorrectly configured MDC clock) I made a few changes to the
at803x driver.
Due to lack of other hardware I could only test these changes with an
AR8030 chip.


Martin
