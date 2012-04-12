From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Regression due to "ath9k: fix going to full-sleep on PS idle"
Date: Thu, 12 Apr 2012 09:20:13 -0400
Message-ID: <20120412132013.GA21495@tuxdriver.com>
References: <CA+55aFxWD1bE0oiR4GpLP19MCm2CzwuApuYhcE_NF7bC+tFYjg@mail.gmail.com>
 <20358.25376.230264.236893@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Heinz Diehl <htd@fancy-poultry.org>,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@venema.h4ckr.net>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20358.25376.230264.236893@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 12, 2012 at 10:37:44AM +0530, Sujith Manoharan wrote:
> Linus Torvalds wrote:
> > You guys need to fix the subject line (like this), and make sure that
> > the right people are cc'd. This is not a "stable" issue - stable
> > cannot revert stuff that hasn't been reverted upstream.
> > 
> > So instead of stable and Greg, it should be netdev and Davem.
> > 
> > David/John: multiple people are complaining about that commit. It
> > really should be reverted, or a fix found. It's broken.
> > 
> > I can do the revert, but it would be better coming from the networking people.
> 
> John has already reverted the commit:
> http://git.kernel.org/?p=linux/kernel/git/linville/wireless.git;a=commit;h=011afa1ed8c408d694957d2474d89dc81a60b70c

Yes, I'll be pushing to Dave M shortly.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
