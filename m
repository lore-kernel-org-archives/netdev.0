From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] pktgen dependency (was: Re: Linux 2.4.27-pre1)
Date: Fri, 23 Apr 2004 16:39:38 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040423163938.013f362f.davem@redhat.com>
References: <20040422130651.GB18358@logos.cnet>
	<Pine.GSO.4.58.0404231644470.15793@waterleaf.sonytel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
In-Reply-To: <Pine.GSO.4.58.0404231644470.15793@waterleaf.sonytel.be>
List-Id: netdev.vger.kernel.org

On Fri, 23 Apr 2004 16:58:58 +0200 (MEST)
Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> The packet generator doesn't compile if procfs is disabled.
> IIRC, there was an agreement that this dependency is needed:

Applied, thanks Geert.  Can you cook up a 2.6.x variant as well
if that is needed too?

Thanks again.
