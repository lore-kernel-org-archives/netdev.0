From: James Morris <jmorris@redhat.com>
Subject: Re: Crypto tests via tcrypt.o modules failes
Date: Thu, 16 Sep 2004 15:25:44 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0409161524190.4676-100000@thoron.boston.redhat.com>
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

> Details are here,http://www.gemtek.lt/~zilvinas/crypto/tcrypt-tests

AES is failing, but it has proven to be endian safe on other 
architectures.


Where does the 'fig' come from in:

<4>decrypt: fig

Can you try a completely unpatched kernel?


- James
-- 
James Morris
<jmorris@redhat.com>
