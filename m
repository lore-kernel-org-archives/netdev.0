From: James Morris <jmorris@redhat.com>
Subject: Re: Crypto tests via tcrypt.o modules failes
Date: Thu, 16 Sep 2004 15:29:10 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0409161528250.4676-100000@thoron.boston.redhat.com>
References: <1095358282.3359.83.camel@swoop.gemtek.lt>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Zilvinas Valinskas <zilvinas@gemtek.lt>
In-Reply-To: <1095358282.3359.83.camel@swoop.gemtek.lt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004, Zilvinas Valinskas wrote:

> I would say Xscale IXP425 has a rather interesting 32, 16 bits
> read/write results if address is not aligned properly.

Odd, no other algorithms seem to be having any problems.  Can you post 
your .config?


- James
-- 
James Morris
<jmorris@redhat.com>
