From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.1] dst_gc_timer initialization
Date: Mon, 19 Jan 2004 20:57:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119205736.5ae0c42d.davem@redhat.com>
References: <400C72CF.9020906@cipherica.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alex Pankratov <ap@cipherica.com>
In-Reply-To: <400C72CF.9020906@cipherica.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 19 Jan 2004 16:14:07 -0800
Alex Pankratov <ap@cipherica.com> wrote:

> The second and third parameters of TIMER_INITIALIZER macro, which is 
> used to initialize dst_gc_timer, are swapped. The patch puts them into 
> the right order.

Patch applied, thanks Alex.
