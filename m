From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] UDP select handling of bad checksums.
Date: Tue, 30 Nov 2004 21:49:51 -0800
Message-ID: <20041130214951.0e216ceb.davem@davemloft.net>
References: <20041102162454.3f153ff0@dxpl.pdx.osdl.net>
	<20041103005253.GA77817@gaz.sfgoth.com>
	<20041122100907.2ab81f18@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mitch@sfgoth.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041122100907.2ab81f18@dxpl.pdx.osdl.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Nov 2004 10:09:07 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Alternate workaround for blocking usage of select() by UDP applications.

Ok, I've applied this to my 2.6.x tree.

Please provide a 2.4.x backport, it needs this too.
