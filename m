From: jamal <hadi@cyberus.ca>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: 22 Apr 2004 11:17:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082647046.1099.47.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0404221030240.2738-100000@paix.pilosoft.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: alex@pilosoft.com
In-Reply-To: <Pine.LNX.4.44.0404221030240.2738-100000@paix.pilosoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-04-22 at 10:37, alex@pilosoft.com wrote:
> On 22 Apr 2004, jamal wrote:
> > Its infact harder to create this attack compared to a simple
> > SYN attack.
> Not quite. 

I meant a SYN Flood attack is a much trivial attack than this
but the media may have gotten used to it by now.

> > Unless i misunderstood: You need someone/thing to see about 64K packets
> > within a single flow to make the predicition so the attack is succesful.
> > Sure to have access to such capability is to be in a hostile path, no?
> > ;->
> No, you do not need to see any packet. 
> 

Ok, so i misunderstood then. How do you predict the sequences without
seeing any packet?
Is there any URL to mentioned paper?

> Inter-provider BGP is long-lived with close to fixed ports, which is why 
> it has caused quite a stir.

Makes sense. What would be the overall effect though? Route flaps?

> Nevertheless, number of packets to kill the session is still *large* 
> (under "best-case" for attacker, you need to send 2^30 packets)...

;->

cheers,
jamal
