From: "David S. Miller" <davem@redhat.com>
Subject: Re: HTB 2.6.0-test10 oops related patch
Date: Sun, 7 Dec 2003 15:29:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031207152931.33e8c3fd.davem@redhat.com>
References: <20031206231047.01257548.davem@redhat.com>
	<Pine.LNX.4.33.0312071218400.635-200000@devix>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, daniel.blueman@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: devik <devik@cdi.cz>
In-Reply-To: <Pine.LNX.4.33.0312071218400.635-200000@devix>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 7 Dec 2003 12:30:20 +0100 (CET)
devik <devik@cdi.cz> wrote:

> I just spotted the second bug too. (For those interested it is described
> in the patch).
> Please revert the small patch I sent you yesterday before applying the
> new one. It contains yesterday's one too (it is because it is for 2.4 too).
> Please apply it against both 2.4.23 and 2.6.0-test10. It should apply
> cleanly in 2.4.23 case and with some offsets to 2.6.0-test10.

Great work, applied.

Thanks.
