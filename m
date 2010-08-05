From: Kiran P <kiran.kiranp@gmail.com>
Subject: SCTP Bundling Timeout value in linux
Date: Thu, 5 Aug 2010 09:53:40 +0530
Message-ID: <AANLkTi=PXuUh8=aLPS3WwL6GMiGem4emHg_Cuck3rzW+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41386 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116Ab0HEEXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 00:23:44 -0400
Received: by wwj40 with SMTP id 40so7319932wwj.1
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 21:23:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is there any SCTP bundling timeout value in linux?
When I checked the code and sysctl, I could find only sack timeout but
no bundling timeout..

-- 
Kiran
