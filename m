From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH RESEND] 2.[46]: Set ARP hw type correctly for BOOTP over
 FDDI
Date: Tue, 5 Oct 2004 12:53:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005125300.106abab9.davem@davemloft.net>
References: <Pine.LNX.4.58L.0410040310550.22545@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <Pine.LNX.4.58L.0410040310550.22545@blysk.ds.pg.gda.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Oct 2004 23:56:59 +0100 (BST)
"Maciej W. Rozycki" <macro@linux-mips.org> wrote:

>  Using the Ethernet ARP hw type for FDDI networks is mandated by RFC 1390
> (STD 36) and that code is already used by Linux elsewhere, but not for
> BOOTP requests sent for IPv4 autoconfiguration.  Here is a patch for both
> 2.4 and 2.6 that fixes the problem for me.  Please apply.
> 
>  Applies both to 2.4.27 and to 2.6.8.1.

Patch applied, thanks.
