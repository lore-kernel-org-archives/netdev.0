From: "David S. Miller" <davem@redhat.com>
Subject: Re: [TRIVIAL PATCH] export dev->state via sysfs
Date: Tue, 19 Aug 2003 22:03:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819220322.5b4911eb.davem@redhat.com>
References: <1061355896.10843.22.camel@camp4.serpentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Bryan O'Sullivan" <bos@serpentine.com>
In-Reply-To: <1061355896.10843.22.camel@camp4.serpentine.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 19 Aug 2003 22:04:56 -0700
"Bryan O'Sullivan" <bos@serpentine.com> wrote:

> This trivial patch exports the netdev state field via sysfs.  The
> motivation is to make it possible to check link state from userspace
> without having to go through the netlink interface.

Please use ethtool.
