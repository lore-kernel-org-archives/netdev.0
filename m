From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device cleanup
Date: Sat, 7 Jun 2003 15:16:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030607191628.GC3346@gtf.org>
References: <20030606145835.3a263df8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030606145835.3a263df8.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

IOW, release_netdev is basically a search-n-replace change that can be done
to drivers anytime.  Let's apply the "meat" changes to mainline first,
the bug fixes / cleanups to use dynamic alloc.

	Jeff
