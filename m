From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix bridge timer race
Date: Tue, 22 Jul 2003 20:54:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030722205457.227847c2.davem@redhat.com>
References: <20030722234508.0af40e80.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, linux@mautner.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030722234508.0af40e80.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jul 2003 23:45:08 -0400
Stephen Hemminger <shemminger@osdl.org> wrote:

> This should fix several startup/shutdown timer races in the bridge
> driver.  Added some paranoia checks for dangling timers.

Applied, thanks.
