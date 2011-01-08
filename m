From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: TCPCT API update for 2.6.37
Date: Sat, 08 Jan 2011 16:36:47 -0500
Message-ID: <4D28D8EF.5010008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:33640 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641Ab1AHVgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jan 2011 16:36:50 -0500
Received: by iyi12 with SMTP id 12so16727386iyi.19
        for <netdev@vger.kernel.org>; Sat, 08 Jan 2011 13:36:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the recent flurry of messages related to TCPCT, I devoted a nice
snowy Saturday afternoon to updating the socket option code.  Linux is
rather fair behind on TCPCT implementation, so this will help with
future software compatibility.

I'm not on this list, so anybody with comments should CC me.  Thanks.
