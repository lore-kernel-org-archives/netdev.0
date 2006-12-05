From: Sebastian Krahmer <krahmer@suse.de>
Subject: TCP dynamic system
Date: Tue, 5 Dec 2006 10:59:20 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0612051056180.12433@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49077 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759904AbWLEJ7W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 04:59:22 -0500
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 6692321756
	for <netdev@vger.kernel.org>; Tue,  5 Dec 2006 10:59:20 +0100 (CET)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Does anyone know a good book on the nature of TCP? Means,
how does all the algorithms (Nagle, ...) delayed, quick, opt-ack,
winodw-size, MSS etc. affect the thruput and so on? Something
that explains (hopefully as good as TCP Illustrated) which parameters
cause what effects. There are some papers which describe this or
that single topic but not a whole view.
I am not subscribed to the list, so please take me into Cc or
answer off-list :-)

thx,
Sebastian

-- 
~
~ perl self.pl
~ $_='print"\$_=\47$_\47;eval"';eval
~ krahmer@suse.de - SuSE Security Team
~

