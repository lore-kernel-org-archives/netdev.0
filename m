From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Date: Mon, 17 Feb 2014 21:30:57 +0100
Message-ID: <20140217203057.GJ4559@pd.tnic>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>
 <20140215203015.GA4528@pd.tnic>
 <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <20140215232508.GB4508@pd.tnic>
 <1392571653.44773.4.camel@leira.trondhjem.org>
 <1392667974.22806.YahooMailNeo@web140003.mail.bf1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	"mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org" <mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: John <da_audiophile-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1392667974.22806.YahooMailNeo-KjDqn544//seBhY5O9xny5EhsgyP+Z75VpNB7YpNyf8@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 17, 2014 at 12:12:54PM -0800, John wrote:
> Trond. =C2=A0Yes, your patch fixes the regression for me; tested on
> v3.13.3, =C2=A0I do not know the process by which patches get into
> the next stable release (minor version). =C2=A0My hope is that once
> peer-reviewed, this patch gets into the 3.13.4 and since the 3.12
> series is not EOL yet, into 3.12.12 as well. =C2=A0Thank you for the =
time
> and effort!

Basically you say

Tested-by: John <da_audiophile-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>

Trond adds stable to CC, sends it to Linus and it trickles down to
3.12.x and 3.13.x stable.

--=20
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
