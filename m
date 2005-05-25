From: Jirka Bohac <jbohac@suse.cz>
Subject: Re: [0/5] Improvements to the ieee80211 layer
Date: Wed, 25 May 2005 10:29:57 +0200
Message-ID: <20050525082956.GA20739@dwarf.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz> <20050524185241.GB2470@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Machek <pavel@suse.cz>
Content-Disposition: inline
In-Reply-To: <20050524185241.GB2470@elf.ucw.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 08:52:41PM +0200, Pavel Machek wrote:
> > This is the first series of patches that try to convert it to a generic
> > IEEE 802.11 layer, usable for most of today's wireless cards.
> 
> Are they against -rc4-mm2?

No, they're against -rc3-mm3. The whole ieee80211 layer has been
accidentally removed from -rc4-mm3 (see
http://lkml.org/lkml/2005/5/18/57 )

> Would it be possible to put agregate patch on the web somewhere (or
> git tree?). I would certainly be easier to test....

Hmm, always thought that small patches would be preferred ;-)
Here you go: http://jikos.cz/~jbohac/tmp/big_80211_patch_01.patch.bz2
This is combined from all the 11 patches we posted yesterday


regards,

-- 
Jirka Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CR
