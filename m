From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 20:20:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16177.18187.429888.128929@robur.slu.se>
References: <16177.13435.45921.229742@robur.slu.se>
	<200308061758.VAA01743@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se (Robert Olsson), davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200308061758.VAA01743@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


kuznet@ms2.inr.ac.ru writes:

 > I think you did not apply patch, which is responsible for repairing
 > rcu troubles.
 > 
 > Alexey

 No correct RCU patches are not applied but even before the RCU pathes we 
 didn't see dst cache overflow during DoS if the routing table was fully 
 loaded and we used hash chain limit patch. 

 Cheers.
						--ro
