From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NET]: TSO requires SG, enforce this at device registry.
Date: Sun, 24 Oct 2004 22:57:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041024225700.4a22a968.davem@davemloft.net>
References: <200410221715.i9MHFlIu021927@hera.kernel.org>
	<417C9431.6030505@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <417C9431.6030505@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Oct 2004 01:50:41 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> 1) Given current driver implementations of ethtool ioctls, sysadmin is 
> free to create a combination of bits that are IMHO a bug.  One can argue 
> that this is an extension of "root can shoot himself in the foot", so 
> who knows.

I made a followon posting proposing ethtool changes which
would enforce the rules there too, did you see it?
