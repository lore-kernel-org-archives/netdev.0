From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: disablenetwork() syscall?
Date: Mon, 7 Jul 2003 14:03:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030707210310.GA21759@gaz.sfgoth.com>
References: <Pine.LNX.4.44.0307072237560.11843-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0307072237560.11843-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pekka Savola wrote:
> In a bugtraq thread, DJ Bernstein brought up an idea which I'm not sure 
> has been brought up in the past.  I'm not sure whether it's feasible or 
> not, but at least it (and other methods to limit the functions of a 
> user-level code) might bear consideration.

It sounds like something that could be a implemented as a capability
(CAP_NET_ACCESS or such)

-Mitch
