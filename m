From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] depca: release resources on errors
Date: Sun, 25 Jan 2004 19:30:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040125193017.450d6ff8.rddunlap@osdl.org>
References: <20040124223109.1c134ca1.rddunlap@osdl.org>
	<4013F096.4090705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ogasawara@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4013F096.4090705@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 25 Jan 2004 11:36:38 -0500 Jeff Garzik <jgarzik@pobox.com> wrote:

| Most of these patches you're sending are already in netdev-2.6, AFAICS...


net: remove unnecessary type casting -- not found in netdev

tc35815: handle ioremap() failure -- still missed (*Leann)

depca: release resource on errors -- yes, already in netdev

dgrs: add iounmap()s to failure paths -- still missed (*Leann)

--
~Randy


*Leann:  Please rediff these 2 patches after Jeff's netdev
patches are merged, or rediff them against his patchsets.
  http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/
