From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Sun, 20 Oct 2002 22:00:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15795.2902.180818.661384@robur.slu.se>
References: <3DB1D6B5.6080305@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DB1D6B5.6080305@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ben Greear writes:
 > The latest NAPI tulip patch I could find (tulip-020922.pat)
 > will not load.  The problem appears that the tulip_misc.c file
 > no longer exists...

 :-( I'll look into it.


 > If anyone has a newer patch, I'd love to try it out.
 
Try Jamal's drop-in-replacement
http://www.cyberus.ca/~hadi/patches/tulip-napi.tgz

Cheers.
						--ro
