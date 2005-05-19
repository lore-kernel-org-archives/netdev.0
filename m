From: James Morris <jmorris@redhat.com>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 09:16:37 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0505190915010.15522-100000@thoron.boston.redhat.com>
References: <20050518222729.007887b8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, <netdev@oss.sgi.com>,
        Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050518222729.007887b8.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 May 2005, Andrew Morton wrote:

> cn_init() uses NETLINK_NFLOG.  Peculiar.

I raised this some time ago, and it was never fixed by the author.


- James
-- 
James Morris
<jmorris@redhat.com>
