From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH v2] pppoe: Lacks DST MAC address check
Date: Mon, 20 Apr 2015 19:02:06 +0000
Message-ID: <1429556526.24234.12.camel@transmode.se>
References: <1429350794-17170-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <20150420.141158.32627615256852547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.transmode.se ([31.15.61.139]:55841 "EHLO smtp.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751663AbbDTTCK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 15:02:10 -0400
In-Reply-To: <20150420.141158.32627615256852547.davem@davemloft.net>
Content-Language: en-US
Content-ID: <DCCE7FCA44CEA24EA53336C0EAE6262F@transmode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-04-20 at 14:11 -0400, David Miller wrote:
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Sat, 18 Apr 2015 11:53:14 +0200
> 
> > A pppoe session is identified by its session ID and MAC address.
> > Currently pppoe does not check if the received pkg has the correct
> > MAC address. This is a problem when the eth I/F is in promisc mode
> > as then any DST MAC address is accepted.
> 
> Please read Documentation/SubmittingPatches in the source tree, you
> need to provide a proper signoff.

Arg! I know this but this time it slipped my mind :(
So sorry, I will send a v3 soon.

 Jocke