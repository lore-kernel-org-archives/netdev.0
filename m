From: Stefan Rompf <srompf@isg.de>
Subject: Re: martian packet checks breaks multi-homing
Date: Tue, 1 Jul 2003 11:11:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307011111.26762.srompf@isg.de>
References: <Pine.LNX.4.56.0307010921100.5910@tekla.ing.umu.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Niklas Edmundsson <Niklas.Edmundsson@hpc2n.umu.se>, netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.56.0307010921100.5910@tekla.ing.umu.se>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Dienstag, 1. Juli 2003 09:37 schrieb Niklas Edmundsson:

> The problem is that when a client tries to talk to the main interface
> of the server (not on the same network), the server tags the packets
> as martian source and discards them! It's a perfectly valid packet

> If things are unclear or I have forgotten/missed something just tell
> me so and I'll try to clarify.

Have a look at linux/Documentation/networking/ip-sysctl.txt, rp_filter

Stefan

-- 
"doesn't work" is not a magic word to explain everything.
