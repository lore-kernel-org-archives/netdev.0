From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Remove i_sock
Date: Thu, 31 Mar 2005 22:39:04 -0800
Message-ID: <20050331223904.00abd02d.davem@davemloft.net>
References: <20050326013742.GP21986@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20050326013742.GP21986@parcelfarce.linux.theplanet.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Mar 2005 01:37:42 +0000
Matthew Wilcox <matthew@wil.cx> wrote:

> 
> Remove i_sock from struct inode.  Also remove some checks for SOCKET_I()
> returning NULL -- it can never return NULL for a valid inode.
> 
> Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Looks good, applied.

Thanks Matthew.
