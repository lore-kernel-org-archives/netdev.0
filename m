From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Fri, 30 Nov 2007 11:34:26 +1100
Message-ID: <20071130003426.GJ23769@gondor.apana.org.au>
References: <1195893216.4149.186.camel@johannes.berg> <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <4748855C.5090103@linux-foundation.org> <474C50D7.5010901@zytor.com> <20071129131107.GC8487@gondor.apana.org.au> <474EFBEB.5000804@zytor.com> <20071130002621.GI23769@gondor.apana.org.au> <474F5932.1030103@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <474F5932.1030103-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 04:28:34PM -0800, H. Peter Anvin wrote:
>
> >sky2 is the exception here, not the rule.
> 
> It is, but it's not unique.  Several USB adapters have the same problem, 
> for example.

Notice the common theme here that slow (or slower, i.e., certainly nowhere
near 10Gb) NICs are the norm for violating alignment :)

So I'd prefer something that only penalised them rather than everybody
else.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
