From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: [Kernel-janitors] old ioctl definitions in 2.5
Date: Mon, 15 Sep 2003 15:54:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915155415.73c5056d.davem@redhat.com>
References: <20030915155225.3cf90d79.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20030915155225.3cf90d79.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Sep 2003 15:52:25 -0700
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> I think that we need to ask the netdev people about this...

If the current generation of the bonding userland tools
have stopped using these older ioctl values, yes we should
kill them from the entire kernel tree.
