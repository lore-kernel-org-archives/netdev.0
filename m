From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 07:16:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030061653.GA22838@infradead.org>
References: <1099030958.4944.148.camel@uganda> <4182A05F.1080505@errno.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Leffler <sam@errno.com>
Content-Disposition: inline
In-Reply-To: <4182A05F.1080505@errno.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2004 at 12:56:15PM -0700, Sam Leffler wrote:
> I realize this suggestion will be met with the usual boo's and catcalls 
> but it'd also be nice if all systems could share a common user-level api 
> so, for example, you could just _use_ the support in openssl that's been 
> around for several years.

Does FreeBSD have a less broken user API than OpenBSD?  The OpenBSD API
had been implemented for Linux and had been rejected dueto execessive
bogusness.
