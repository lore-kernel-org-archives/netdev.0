From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Multicast snooping fixes and suggestions
Date: Thu, 24 Feb 2011 13:42:32 +0800
Message-ID: <20110224054232.GA26064@gondor.apana.org.au>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de> <4D65CD81.4070203@zytor.com> <20110224040412.GA25488@gondor.apana.org.au> <4D65E2B4.1010501@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D65E2B4.1010501@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 23, 2011 at 08:46:44PM -0800, H. Peter Anvin wrote:
>
> I have disabled STP on the bridge; it doesn't change the behavior.

Once you have disabled STP, you can set the forward delay to 0
which should do the trick.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
