From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 12:38:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307241238510034.210E4F24@192.168.128.16>
References: <Pine.LNX.4.44.0307240149480.1181-100000@u.domain.uli>
 <200307240134030339.1EADABD4@192.168.128.16>
 <200307241130.53262.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <200307241130.53262.bdschuym@pandora.be>
To: "Bart De Schuymer" <bdschuym@pandora.be>, "Julian Anastasov" <ja@ssi.bg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24/07/2003 at 11:30 Bart De Schuymer wrote:

>arptables can mangle the arp payload with the "mangle" module. You'll need
>a 
>very recent kernel for this, net/ipv4/netfilter/arpt_mangle.c must exist.
>The 
>userspace code for this is in the CVS at the mentioned site, I haven't
>made a 
>new release yet due to lack of time.


Thanks Bart,

However I don't see how these tools can help in this ARP problem.
There is no need of filtering or mangling arp, the problem is an incorrect arp being sent.

Regards,
Carlos Velasco
