From: James Morris <jmorris@redhat.com>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 13:09:44 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0505191259590.16439-100000@thoron.boston.redhat.com>
References: <20050519095334.018dd674.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: johnpol@2ka.mipt.ru, <herbert@gondor.apana.org.au>, <netdev@oss.sgi.com>,
        <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050519095334.018dd674.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 May 2005, Andrew Morton wrote:

> How come?  It seems sensible to have library code which consoldates the
> common netlink setup and teardown stuff and which offers a higher-level
> messaging API, although connector may be a bit overdesigned for that.  The
> fork connector guys seemed to find it useful?

I don't think it's the right implementation, and providing feedback on it
has proven frustrating and unfruitful.


- James
-- 
James Morris
<jmorris@redhat.com>
