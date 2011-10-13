From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Thu, 13 Oct 2011 17:48:33 +0200
Message-ID: <1318520913.9266.102.camel@sakura.staff.proxad.net>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab>
	 <20111010223752.GB2373@minipsycho>
	 <1318518274.9266.94.camel@sakura.staff.proxad.net>
	 <20111013153850.GA2031@minipsycho>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse@nicira.com, fubar@us.ibm.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bobafett.staff.proxad.net ([213.228.1.121]:49141 "EHLO
	bobafett.staff.proxad.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482Ab1JMPse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 11:48:34 -0400
In-Reply-To: <20111013153850.GA2031@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2011-10-13 at 17:38 +0200, Jiri Pirko wrote:

> Looks like it. The question is what is the correct behaviour... 

since we don't want to break existing setup I would say the current one

but I must admit I'm not a big fan of it.

-- 
Maxime
