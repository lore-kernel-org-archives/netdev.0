From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ipvs -- fix error's in list_for_each changes.
Date: Tue, 23 Sep 2003 03:59:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923035951.63d89345.davem@redhat.com>
References: <20030916141750.53bbb04e.shemminger@osdl.org>
	<Pine.LNX.4.44.0309210934460.1468-100000@u.domain.uli>
	<20030922112204.225e1a98.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, wensong@linux-vs.org, lvs-users@LinuxVirtualServer.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030922112204.225e1a98.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 22 Sep 2003 11:22:04 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The earlier list_for_each changes introduced a couple of bugs where
> lines got dropped.  This restores them.

Applied, thanks Stephen.
