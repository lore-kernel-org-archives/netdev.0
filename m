From: James Morris <jmorris@redhat.com>
Subject: Re: [Openswan dev] IPComp
Date: Tue, 6 Jul 2004 12:43:10 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407061241090.23212-100000@thoron.boston.redhat.com>
References: <Xine.LNX.4.44.0407061031090.22633-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dev@lists.openswan.org, <netdev@oss.sgi.com>,
        Paul Wouters <paul@xelerance.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <Xine.LNX.4.44.0407061031090.22633-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004, James Morris wrote:

> We should not perform this allocation for each packet.

Well, actually, IPComp is so slow that it may not do much more damage to 
performance.


- James
-- 
James Morris
<jmorris@redhat.com>
