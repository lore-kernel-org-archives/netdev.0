From: James Morris <jmorris@redhat.com>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 09:19:33 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0505190918430.15522-100000@thoron.boston.redhat.com>
References: <20050519000809.2fca25c5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: johnpol@2ka.mipt.ru, <herbert@gondor.apana.org.au>, <netdev@oss.sgi.com>,
        <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050519000809.2fca25c5.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 May 2005, Andrew Morton wrote:

> We should remove the feature.  If there is demonstrated need for multiple
> instances then it should be done by more conventional means - syscall,
> allocation of a device major then use the minor as a selector or whatever.

I'd suggest removing the connector code completely.


- James
-- 
James Morris
<jmorris@redhat.com>
