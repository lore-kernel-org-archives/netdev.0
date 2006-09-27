From: Jiri Benc <jbenc@suse.cz>
Subject: Re: softmac mtu
Date: Wed, 27 Sep 2006 14:39:05 +0200
Message-ID: <20060927143905.721ddf3e@griffin.suse.cz>
References: <ef3s4u$or5$3@sea.gmane.org>
	<ef9a0b$4jb$4@sea.gmane.org>
	<20060925200125.GF16949@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matthieu CASTET <castet.matthieu@free.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:12228 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932308AbWI0MjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 08:39:07 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060925200125.GF16949@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Sep 2006 16:01:32 -0400, John W. Linville wrote:
> On Mon, Sep 25, 2006 at 07:17:31PM +0000, Matthieu CASTET wrote:
> > So why a special mtu handler is not implemented in 802.11 stack :
> > - 802.11 stack doesn't support bigger packet
> > - 802.11 stack doesn't support very bigger packet (with
> > 802.11 fragmentation)
> > - 802.11 writers were lazy
> 
> I suspect the latter...patches welcome! :-)

d80211 supports larger MTU.

 Jiri

-- 
Jiri Benc
SUSE Labs
