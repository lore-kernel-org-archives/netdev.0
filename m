From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Use unlocked_ioctl for sock_ioctl
Date: Mon, 17 Jan 2005 14:44:31 -0800
Message-ID: <20050117144431.587a739f.davem@davemloft.net>
References: <20050117222335.GC10882@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20050117222335.GC10882@wotan.suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Jan 2005 23:23:35 +0100
Andi Kleen <ak@suse.de> wrote:

> 
> Now that unlocked_ioctl has been merged use it for sock_ioctl.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

Applied, thanks Andi.
