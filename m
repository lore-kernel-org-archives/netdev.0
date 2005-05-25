From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [0/5] Improvements to the ieee80211 layer
Date: Wed, 25 May 2005 11:42:07 +0200
Message-ID: <20050525114207.63601e5b@griffin.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz>
	<20050524185241.GB2470@elf.ucw.cz>
	<20050525082956.GA20739@dwarf.suse.cz>
	<20050525092710.GA1926@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jirka Bohac <jbohac@suse.cz>, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Machek <pavel@suse.cz>
In-Reply-To: <20050525092710.GA1926@elf.ucw.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 May 2005 11:27:10 +0200, Pavel Machek wrote:
> net/ieee80211/ieee80211_rx.c:281: error: `dev' undeclared (first use
> in this function)

Thanks, we had CONFIG_IEEE80211_CRYPT_TKIP disabled when testing as
there seem to be more important things to deal with. Will be fixed in
the next patch series.


-- 
Jiri Benc
SUSE Labs
