From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] handle module ref count on sysctl tables.
Date: Wed, 21 Dec 2005 19:20:54 +0000
Message-ID: <20051221192054.GN27946@ftp.linux.org.uk>
References: <20051221103520.258ced08@dxpl.pdx.osdl.net> <20051221190849.GM27946@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751210AbVLUTU4@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20051221190849.GM27946@ftp.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2005 at 07:08:49PM +0000, Al Viro wrote:
> Solution is fairly simple:

Just to clarify: said solution is already in the tree...
