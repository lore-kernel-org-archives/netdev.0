From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Mon, 30 Jul 2007 18:38:25 -0400
Message-ID: <46AE6861.50004@garzik.org>
References: <20070730212333.GA8049@havoc.gtf.org> <alpine.LFD.0.999.0707310349460.17287@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Petko Manolov <petkan@users.sourceforge.net>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53841 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755410AbXG3Wi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 18:38:29 -0400
In-Reply-To: <alpine.LFD.0.999.0707310349460.17287@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

true, we should just remove the dev==NULL check

