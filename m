From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] atalk: remove gcc warning when PROC_FS=n
Date: Wed, 26 Jan 2005 23:37:39 -0800
Message-ID: <20050126233739.6d51b0b5.davem@davemloft.net>
References: <41F736E6.6000901@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <41F736E6.6000901@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 22:21:26 -0800
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> appletalk: Fix gcc warning.
> 
> with CONFIG_PROC_FS=n, gcc complains:
> net/appletalk/ddp.c:1893: warning: statement with no effect

Applied, thanks Randy.
