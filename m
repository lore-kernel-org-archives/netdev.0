From: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
Subject: Re: Shared i2c adapter locking
Date: Tue, 17 Nov 2009 10:35:54 +0100
Message-ID: <20091117103554.03971b2f@hyperion.delvare>
References: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
	<20091029154317.651904b9@hyperion.delvare>
	<1256828976.2827.27.camel@achroite>
	<20091105141122.56b6b4f8@hyperion.delvare>
	<1257429444.2793.2.camel@achroite.uk.solarflarecom.com>
	<20091105150715.692b5200@hyperion.delvare>
	<20091117193313.b750804e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mika Kuoppala <mika.kuoppala-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	Linux I2C <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091117193313.b750804e.sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Tue, 17 Nov 2009 19:33:13 +1100, Stephen Rothwell wrote:
> Hi Jean,
> 
> On Thu, 5 Nov 2009 15:07:15 +0100 Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org> wrote:
> >
> > > Presumably this is meant for net-next-2.6, and you'll implement
> > 
> > Actually I meant to push this to Linus immediately, through my i2c
> > tree. This is essentially a no-op: the binary code will be the same as
> > before the patch, so guaranteed to be safe, and this will solve
> > conflicts in linux-next.
> 
> Any word on this?

Haven't you read this:
http://www.spinics.net/lists/linux-next/msg07839.html

and the 3 following posts?

If you did and something is still not clear, please let me know. My
understanding is that the action token is in David's hands now.

-- 
Jean Delvare
