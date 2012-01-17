From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2012-01-16
Date: Tue, 17 Jan 2012 10:45:21 -0500
Message-ID: <20120117154521.GF12733@tuxdriver.com>
References: <20120116195435.GB12733@tuxdriver.com>
 <20120116.201507.597966888285215358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120116.201507.597966888285215358.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 16, 2012 at 08:15:07PM -0500, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Mon, 16 Jan 2012 14:54:35 -0500
> 
> > Here is a set of fixes for 3.3 that I let cook over the weekend...
> > 
> > Included is a fix for a signedness bug in ipw2x00 from Dan Carpenter, a
> > fix for an oops when ejecting a b43 card from Guennadi Liakhovetski
> > (with a minor modification by me as noted in the changelog), a mac80211
> > regresion fix from Johannes Berg for a bug related to station
> > management, and a final fix for the rt2800pci spurious interrupt issue
> > from Stanislaw Gruszka.
> 
> And Linus's patches to fix the brcmsmac driver aren't in here because?
> 
> If you don't integrate them, Linus is going to integrate them on his
> own before -rc1 is cut, so whatever you're "waiting for" is entirely
> and utterly pointless.
> 
> Merge his bug fixes now, don't delay this kind of stuff, ever.

OK, I withdraw this pull request.  I'll send a replacement immediately.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
