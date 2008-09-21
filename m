From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Mon, 22 Sep 2008 00:43:07 +0300
Message-ID: <200809220043.07345.denys@visp.net.lb>
References: <20080921182835.GA11473@2ka.mipt.ru> <20080921140203.4698a2ee@infradead.org> <20080921210554.GA2135@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ipw2100-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, yi.zhu@intel.com,
	reinette.chatre@intel.com, jgarzik@pobox.com,
	linville@tuxdriver.com, davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753628AbYIUVpl@vger.kernel.org>
In-Reply-To: <20080921210554.GA2135@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 22 September 2008, Evgeniy Polyakov wrote:
> On Sun, Sep 21, 2008 at 02:02:03PM -0700, Arjan van de Ven 
(arjan@infradead.org) wrote:
> > > That allows to dump whatever number of warnings you want. The more we
> > > have, the louder will be customers scream.
> >
> > artificially increasing numbers isn't going to do that; it just shows
> > you're more interested in making a stink than in getting something
> > improved ;(
>
> As practice shows, I'm the only one who is interested in getting
> something improved, and Intel, as we see right now, is not interested in
> it at all, since you ask me not only decrease error verbosity, but also
> do not work towards fixing the bug by trying to understand where it
> lives.

You are not right. I had totaly disfunctional Intel driver on two laptops and 
reported about issue to Intel. Yes it took time, they took all debugs and 
went coma mode (i was thinking that), but suddently i got mail from them, and 
next kernel/firmware release worked for me flawlessly. So they did perfect 
job.

Don't be negative and prepare yourself for giving long debug outputs. Patience 
and only patience.
