From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: commit 0bdb0bd0 breaks shutdown/reboot
Date: Mon, 7 Nov 2011 16:57:20 -0800
Message-ID: <20111107165720.59e4eb13@nehalam.linuxnetplumber.net>
References: <20111107153119.GA11724@comet.dominikbrodowski.net>
	<20111107081316.2e1cc2cb@nehalam.linuxnetplumber.net>
	<20111107163227.GA17798@isilmar-3.linta.de>
	<20111107084540.7ffc913f@nehalam.linuxnetplumber.net>
	<20111107170814.GA7657@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51734 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751205Ab1KHA5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 19:57:22 -0500
In-Reply-To: <20111107170814.GA7657@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can reproduce on my laptop, let me investigate.
