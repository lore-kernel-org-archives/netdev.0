From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: possible bridge regression in "bridge: implement
 [add/del]_slave ops"?
Date: Tue, 5 Jul 2011 14:28:58 -0700
Message-ID: <20110705142858.3b7e5941@nehalam.ftrdhcpuser.net>
References: <201106301033.23997.alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43142 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751329Ab1GEV3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 17:29:40 -0400
In-Reply-To: <201106301033.23997.alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just put a fix for the detection of bridge pseudo-device being up
into the current rstp code available at:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/rstp.git
