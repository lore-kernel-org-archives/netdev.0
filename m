From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/3] fix buggy IEEE80211_CRYPT_* selects
Date: Wed, 09 Mar 2005 15:21:23 -0500
Message-ID: <422F5AC3.1010103@pobox.com>
References: <200503041237.j24Cbb69026470@shell0.pdx.osdl.net> <42289BDF.1080409@pobox.com> <20050304221014.GJ3327@stusta.de> <4228DF62.4000205@pobox.com> <20050304230718.GL3327@stusta.de> <20050306090936.GA31890@gondor.apana.org.au> <422B4552.5000504@pobox.com> <20050306210937.GA3233@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, akpm@osdl.org, davem@davemloft.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050306210937.GA3233@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sun, Mar 06, 2005 at 01:00:50PM -0500, Jeff Garzik wrote:
> 
>>I would rather fix Kconfig.  If we are selecting X_1 -- which explicitly 
>>depends on X -- when Kconfig should automatically select X.
> 
> 
> That would be nice to have.  However, until such a patch is integrated
> we need to write Kconfig entries that work properly.

Who has contacted the Kconfig maintainer, and asked about this?

	Jeff
