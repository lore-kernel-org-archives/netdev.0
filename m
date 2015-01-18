From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: Wireless scanning while turning off the radio problem..
Date: Mon, 19 Jan 2015 06:40:18 +1200
Message-ID: <CA+55aFws=-MY+rUsEny=DsBx9gct93BnfeGXSnOCLxEFtvDj8A@mail.gmail.com>
References: <CA+55aFyr9LC7oLoJeyFwK4KRURbbUyO63jznTTAkQF+9LBAsfg@mail.gmail.com>
	<CANUX_P0LCr3fzqLyjKQbZ-P2hAV-Nk6=AMm=oFOWCLW34cRg2w@mail.gmail.com>
	<CA+55aFzEr-R1anNm91pnM=ujfhBstJikZBVtduphff1PtccHDw@mail.gmail.com>
	<54BBF207.2030708@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54BBF207.2030708-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 19, 2015 at 5:48 AM, Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>
> So as you indicated you were in location where none of your configured
> networks were available. Flipping the rfkill switch in that situation is the
> way to trigger the issue.

So you certainly seem to be able to explain the behavior I saw under
the circumstances they happened.

I suspect the best thing to do is to just apply your patch. I may not
be able to really test it much for the next few days anyway. Emmanuel?

             Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
