From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert VLAN to use seq_file for /proc
Date: Mon, 28 Jul 2003 16:31:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728163100.7b47ed5e.davem@redhat.com>
References: <20030728153024.6b1d7cde.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, vlan@wanfear.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030728153024.6b1d7cde.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Jul 2003 15:30:24 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Use seq_file interface for smaller, simpler, safer code in /proc.
> Output format is the same.
> 
> Patch for 2.6.0-test2 with earlier proc patches

Applied to 2.6.x, thanks Stephen.
