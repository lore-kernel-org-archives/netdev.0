From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (3/6) ipvs -- use list_for_each_entry macro's
Date: Sat, 20 Sep 2003 01:06:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920010616.2ff3c3d0.davem@redhat.com>
References: <20030916141750.53bbb04e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wensong@linux-vs.org, lvs-users@LinuxVirtualServer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030916141750.53bbb04e.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2003 14:17:50 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> There are many places where list_for_each_entry macro can be used in IPVS
> code.

Looks fine to me, applied thanks.
