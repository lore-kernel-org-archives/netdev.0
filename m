From: oterito <otero1709@hotmail.com>
Subject: Re: [PATCH 2/2]d80211: add hardware scan callback
Date: Mon, 6 Apr 2009 08:12:17 -0700 (PDT)
Message-ID: <22910800.post@talk.nabble.com>
References: <1156494733.21483.14.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kuber.nabble.com ([216.139.236.158]:44327 "EHLO
	kuber.nabble.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbZDFPMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 11:12:19 -0400
Received: from isper.nabble.com ([192.168.236.156])
	by kuber.nabble.com with esmtp (Exim 4.63)
	(envelope-from <lists@nabble.com>)
	id 1LqqUj-0003z7-Ks
	for netdev@vger.kernel.org; Mon, 06 Apr 2009 08:12:17 -0700
In-Reply-To: <1156494733.21483.14.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello, pleas I need help, I triying to scan all AP's in a range, but I have a
problem, I have depreciate SIOIWAPLIST, and also SIOCIWSCAN always return 0.
I dont know If I can put a patch to activate that an wich patch can I use
and how. I'm a begginer user of linux. I'm working with debian etch and I
have a Intel ipw3945 wirelles chipset. Thanks
-- 
View this message in context: http://www.nabble.com/-PATCH-2-2-d80211%3A-add-hardware-scan-callback-tp5979589p22910800.html
Sent from the netdev mailing list archive at Nabble.com.

