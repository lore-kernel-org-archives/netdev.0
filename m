From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] ipconfig accepts any DHCPACK
Date: Tue, 7 Sep 2004 15:43:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907154315.067e9470.davem@redhat.com>
References: <413E2C26.5040108@pantasys.com>
	<20040907150204.119ba849.davem@redhat.com>
	<413E39F2.4070708@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Buckingham <peter@pantasys.com>
In-Reply-To: <413E39F2.4070708@pantasys.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 07 Sep 2004 15:45:06 -0700
Peter Buckingham <peter@pantasys.com> wrote:

> David S. Miller wrote:
>   > Just because there are 16 bytes of hw address in the bootp packet
> > layout doesn't mean the device actually has that many.  Please fix
> > it to use dev->addr_len.
> > 
> 
> is this okay?

yep, looks great, I'll apply it
