From: Andi Kleen <ak@suse.de>
Subject: Virtual device lo asks to queue packet! since -git15
Date: Sat, 21 Jul 2007 09:49:22 +0200
Message-ID: <200707210949.22880.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:41153 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758187AbXGUHt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 03:49:26 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id DF6AF124CF
	for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 09:49:25 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


FYI

Since -git15 (probably David's merge) I see a lot of 

Virtual device lo asks to queue packet!
Virtual device lo asks to queue packet!
Virtual device lo asks to queue packet!
Virtual device lo asks to queue packet!
Virtual device lo asks to queue packet!
Virtual device lo asks to queue packet!

during a LTP run on a nfsroot system

-Andi
 
