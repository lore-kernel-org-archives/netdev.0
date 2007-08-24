From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [XFRM] : Fix pointer copy size for encap_tmpl and coaddr.
Date: Fri, 24 Aug 2007 12:35:48 +0200
Message-ID: <20070824103548.GA894@postel.suug.ch>
References: <20070822145632.087638328@lsx.localdomain> <11879499202750-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33377 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753994AbXHXKf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 06:35:28 -0400
Content-Disposition: inline
In-Reply-To: <11879499202750-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Masahide NAKAMURA <nakam@linux-ipv6.org> 2007-08-24 19:05
> This is minor fix about sizeof argument using with kmemdup().

Thanks for catching this!
