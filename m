From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 7/9] X.25: Dont log "unknown frame type" when receiving
 clear confirm
Date: Thu, 28 Oct 2004 16:48:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028164846.5a67f4f1.davem@davemloft.net>
References: <200410280721.i9S7Lj908010@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, ahendry@tusc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200410280721.i9S7Lj908010@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004 00:19:46 -0700
akpm@osdl.org wrote:

> From: Andrew Hendry <ahendry@tusc.com.au>
> 
> There is no need to log "unknown frame type" when remote X.25 sends clear
> confirms.
> 
> Signed-off-by: Andrew Hendry <ahendry@tusc.com.au>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks.
