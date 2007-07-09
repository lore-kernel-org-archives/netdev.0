From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] Allow LSM to use IP address/port number.
Date: Mon, 9 Jul 2007 19:41:19 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707091940450.10029@d.namei>
References: <200707070225.AFC45609.MNStNTPG@I-love.SAKURA.ne.jp>
 <200707061343.03942.paul.moore@hp.com> <200707090533.l695X1PM059672@www262.sakura.ne.jp>
 <20070709.002629.28788394.davem@davemloft.net>
 <200707092213.HAC58314.WSNFtPGOFUE@I-love.SAKURA.ne.jp>
 <Line.LNX.4.64.0707091842360.9417@d.namei> <20070709160538.289d8ac2@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:51097 "EHLO
	mail7.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760779AbXGIXlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 19:41:23 -0400
In-Reply-To: <20070709160538.289d8ac2@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Jul 2007, Stephen Hemminger wrote:

> Isn't it better to hook into existing netfilter infrastructure somehow?

Yes, it has been suggested several times.


-- 
James Morris
<jmorris@namei.org>
