From: "David S. Miller" <davem@redhat.com>
Subject: Re: b44 module problems
Date: Mon, 28 Jul 2003 07:11:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728071157.0ad6f726.davem@redhat.com>
References: <20030728114302.1cbb6f70.zagarna@yahoo.com>
	<20030728095631.GA6946@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zagarna@yahoo.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20030728095631.GA6946@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Jul 2003 12:56:31 +0300
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> You're not trying to use ipv6 or have the module loaded by any chance? When working
> on the driver I had similar problems with rmmod on 2.5 when the ipv6 module
> was loaded, without it unloading worked just fine (if I understood correctly,
> this is a known problem with all ethernet drivers).

Yes, and this is fixed in 2.6.0-test2
