From: "Tobias Koeck" <tobias.koeck@gmail.com>
Subject: dynamic data structure for the ip address search?
Date: Wed, 27 Aug 2008 15:41:09 +0200
Message-ID: <379e30200808270641x2ec819a7o10903ec46d416260@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:1264 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295AbYH0NlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 09:41:11 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1558755fgg.17
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 06:41:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm searching for a dynamic datastructure where I can easily find if
an IP address is listed in it. After that I want to get the pointer to
the containing datastructure.

The easiest solution would be a circular double bounded list, but is
there some kind of dynamic hash data structure in the kernel headers?

Greetings
tobias
