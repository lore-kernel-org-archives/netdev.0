From: "David S. Miller" <davem@redhat.com>
Subject: Re: HTB 2.6.0-test10 oops related patch
Date: Sat, 6 Dec 2003 23:10:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031206231047.01257548.davem@redhat.com>
References: <4371.1067710407@www6.gmx.net>
	<Pine.LNX.4.33.0312061512320.839-200000@devix>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, daniel.blueman@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: devik <devik@cdi.cz>
In-Reply-To: <Pine.LNX.4.33.0312061512320.839-200000@devix>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 6 Dec 2003 15:18:37 +0100 (CET)
devik <devik@cdi.cz> wrote:

> I discovered reason of the first Daniel's OOPS. It is change
> which was not forward-ported to 2.6.
> It is attached.

Thanks a lot for tracking this problem down Devik.

Patch applied, thanks again.
