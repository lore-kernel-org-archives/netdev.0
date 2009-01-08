From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: Network privilege separation.
Date: Thu, 8 Jan 2009 23:10:27 +1100
Message-ID: <20090108121027.GA3226@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael@laptop.org, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758770AbZAHMKy@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> 
> That to me says controlling network access is only useful as part of a
> more fine grained and general purpose interface. We already have that
> interface in the form of things like SELinux. We already have systems
> actively using it to control stuff like which ports are accessed by some
> services.

Exactly.  If people want this they should go the SELinux/LSM route.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
