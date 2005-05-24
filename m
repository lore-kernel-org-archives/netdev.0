From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Super TSO v3
Date: Tue, 24 May 2005 16:42:19 -0700
Message-ID: <20050524164219.59cc6b01@dxpl.pdx.osdl.net>
References: <20050523.121943.78708600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Harry Edmon <harry@atmos.washington.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050523.121943.78708600.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 May 2005 12:19:43 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> 
> Ok, new version.  This weekend has been productive.
>

I wonder if the TSO stuff would fix the performance problems with MacOSX
and their broken delayed ack?
