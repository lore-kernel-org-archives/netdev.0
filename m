From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 18:36:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307241836060226.006FACEB@192.168.128.16>
References: <Pine.LNX.4.44.0307241922270.10460-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Bart De Schuymer" <bdschuym@pandora.be>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0307241922270.10460-100000@l>
To: "Julian Anastasov" <ja@ssi.bg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24/07/2003 at 19:32 Julian Anastasov wrote:

>	There are some exceptions for the src IP. Even Linux will
>not reply if the src IP in incoming probe matches local IP. But
>may be only Linux preserves the src IP in outgoing probes.

I think so, I don't like that src IP in outgoing probes... but as Windows OS replies to this ARP can't see why Cisco IOS is not replying.
Will open a TAC case tomorrow. I'm interested on testing this in Solaris.

Regards,
Carlos Velasco
