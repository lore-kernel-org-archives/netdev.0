From: James Morris <jmorris@intercode.com.au>
Subject: Re: ipsec without interface
Date: Wed, 2 Jul 2003 00:00:13 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307012359010.29022-100000@excalibur.intercode.com.au>
References: <1057066404.4054.9.camel@simulacron>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bert hubert <ahu@ds9a.nl>, "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Jellinghaus <aj@dungeon.inka.de>
In-Reply-To: <1057066404.4054.9.camel@simulacron>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 1 Jul 2003, Andreas Jellinghaus wrote:

> hmm. I haven't tried to use an explicit ipip tunnel.
> did anyone use ESP in transport mode to encrypt packets
> of an IPIP tunnel? that might help me.

It's known to work on a gre tunnel (if you manually adjust the mtu), so 
ipip probably works.

- James
-- 
James Morris
<jmorris@intercode.com.au>
