From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix cosa to get rid of warnings and build on SMP
Date: Fri, 5 Sep 2003 02:43:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905024345.77bd6953.davem@redhat.com>
References: <20030903173417.GC18025@fs.tum.de>
	<20030904142828.14218966.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030904142828.14218966.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 4 Sep 2003 14:28:28 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> * get rid of leftover sti
> * no longer need MOD_INC/DEC stuff
> * get rid of dead code related to MOD_INC/DEC
> * use module_init/module_exit to cleanly run init code

Applied, thanks.
