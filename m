From: Stanislaw Gruszka <stf_xl@wp.pl>
Subject: Re: [PATCH] net: fix unreg list corruption in dev_deactivate()
Date: Sun, 20 Feb 2011 13:44:03 +0100
Message-ID: <20110220124403.GA2839@localhost.localdomain>
References: <20110220113429.GA27047@localhost.localdomain>
 <1298203890.8559.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.7]:64008 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437Ab1BTMol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Feb 2011 07:44:41 -0500
Content-Disposition: inline
In-Reply-To: <1298203890.8559.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 20, 2011 at 01:11:30PM +0100, Eric Dumazet wrote:
> Hmm, you should read Eric B patch, he already addressed this problem a
> few hours ago.

Ajjj, my few hours of debugging wasted :-/

Stanislaw
