From: Patrick McHardy <kaber@trash.net>
Subject: Re: how to set pppoe source mac address?
Date: Sun, 21 Oct 2007 19:50:57 +0200
Message-ID: <471B9181.8010502@trash.net>
References: <005a01c813e6$fdae6610$5267a8c0@Jocke>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59550 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbXJURva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 13:51:30 -0400
In-Reply-To: <005a01c813e6$fdae6610$5267a8c0@Jocke>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Tjernlund wrote:
> I have several pppoe i/f's over one eth i/f and I want to set the
> source mac address used by each pppoe i/f to a unique mac address from
> user space.
> 
> Is this possible? If so, how do I do that?


Try the macvlan driver.
