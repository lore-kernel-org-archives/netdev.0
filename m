From: James Morris <jmorris@redhat.com>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 01:09:34 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0410310103270.28198-100000@thoron.boston.redhat.com>
References: <4182A175.8050706@errno.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: johnpol@2ka.mipt.ru, jamal <hadi@cyberus.ca>, <netdev@oss.sgi.com>,
        <cryptoapi@lists.logix.cz>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Leffler <sam@errno.com>
In-Reply-To: <4182A175.8050706@errno.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004, Sam Leffler wrote:

> And a paper I wrote explains how I fixed many of the problems with the 
> openbsd code in freebsd.
> 
> http://www.usenix.org/publications/library/proceedings/bsdcon03/tech/leffler_crypto/leffler_crpto_html/

Thanks, that's a useful reference.

For handling overload of crypto hardware, I was thinking of falling back
to software processing (really, I guess this is just load balancing
between hardware and software).


- James
-- 
James Morris
<jmorris@redhat.com>
