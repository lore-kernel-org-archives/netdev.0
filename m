From: James Morris <jmorris@redhat.com>
Subject: Re: af_packet & CHECKSUM_HW
Date: Tue, 18 Nov 2003 22:34:40 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0311182234010.8095-100000@thoron.boston.redhat.com>
References: <20031118174612.48c0854e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Petr Vandrovec <vandrove@vc.cvut.cz>, <herbert@gondor.apana.org.au>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031118174612.48c0854e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Nov 2003, David S. Miller wrote:

> In this way all existing ptype->func() implementations get what
> they expect.  Only if the flag is set will the new behavior occur.
> 
> Comments?

Sounds good.


- James
-- 
James Morris
<jmorris@redhat.com>
