From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Wireless patches to push for 2.6.18?
Date: Sat, 27 May 2006 00:17:27 +0200
Message-ID: <200605270017.27373.mb@bu3sch.de>
References: <20060526195855.GD32487@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:58045
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750903AbWEZWSY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 18:18:24 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060526195855.GD32487@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 26 May 2006 21:59, John W. Linville wrote:
> As David M. so recently reminded us, 2.6.17 is likely to be blessed soon.
> That will open a short merge window for non-"fixes" to go into 2.6.18.
> 
> Along w/ the patches currently on the 'upstream' branch, I'd like to
> see some of the the drivers hanging-out only on the 'master' branch
> of wireless-2.6 to get polished-up and pushed-out.  What do you think
> are the best candidates?
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/master/
> 
> Anyone have anything else they are holding-back for 2.6.18? 

Yes, we would like to merge the big tx-power-rewrite (aka get 4318
working) into the bcm43xx driver, but it is only 90% completed atm.
I guess we still have 1 to 1.5 weeks left, before the window closes?
