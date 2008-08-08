From: "Alexandr Kotov" <ndpismo@gmail.com>
Subject: Changing interface flags
Date: Fri, 8 Aug 2008 12:23:51 +0400
Message-ID: <6dcdc3370808080123r7eb54f83ue3e52e6d46faa6f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.152]:2497 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183AbYHHIXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 04:23:52 -0400
Received: by po-out-1718.google.com with SMTP id c31so1296114poi.1
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2008 01:23:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there any possibility to change interface flags (bring it up) with
IOCTL with kernel which was compiled only with CONFIG_SOCKET and
CONFIG_PACKET options (without CONFIG_INET)?
