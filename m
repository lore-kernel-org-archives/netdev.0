From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (0/7) device_probe enhancement
Date: Tue, 23 Sep 2003 16:39:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923163910.4239ac33.davem@redhat.com>
References: <20030923144721.6001c598.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030923144721.6001c598.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Sep 2003 14:47:21 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This comes from Al Viro's net device patchset and is updated for
> 2.6.0-test5 latest.  It adds a second probe list for network devices
> that are compiled into the kernel, but allocate their own network
> device rather than being handed a device.  It is part of the
> incremental changes to have all network devices using dynamic
> allocation.

This all looks fine to me.  Jeff, what do you think?  Are you gonna
merge it if it's ok to you?
