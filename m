From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] ipv4: mode 0555 in ipv4_skeleton
Date: Tue, 26 Aug 2008 20:06:39 +0100
Message-ID: <20080826190639.GZ28946@ZenIV.linux.org.uk>
References: <Pine.LNX.4.64.0808261950390.4716@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hugh Dickins <hugh@veritas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760445AbYHZTG4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808261950390.4716@blonde.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2008 at 08:00:03PM +0100, Hugh Dickins wrote:
> vpnc on today's kernel says Cannot open "/proc/sys/net/ipv4/route/flush":
> d--------- 0 root root 0 2008-08-26 11:32 /proc/sys/net/ipv4/route
> d--------- 0 root root 0 2008-08-26 19:16 /proc/sys/net/ipv4/neigh
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Al Viro <viro@zeniv.linux.org.uk>
