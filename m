From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] rearrange frto field to save space.
Date: Wed, 21 Apr 2004 16:59:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421165902.549126f0.davem@redhat.com>
References: <20040420155738.4146b5bb.davem@redhat.com>
	<20040421111032.0705b605@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040421111032.0705b605@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 21 Apr 2004 11:10:32 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Since the frto_counter field only goes from 0 to 4, it can be moved
> into a unused byte size hole to save space.

Ok. Applied.
