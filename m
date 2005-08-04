From: Jirka Bohac <jbohac@suse.cz>
Subject: Re: Fwd: opensource atheros driver almost done
Date: Thu, 4 Aug 2005 14:09:14 +0200
Message-ID: <20050804120914.GA1905@dwarf.suse.cz>
References: <aec8d6fc05080215084f955d44@mail.gmail.com> <aec8d6fc050802151125284155@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jbenc@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Mateusz Berezecki <mateuszb@gmail.com>
Content-Disposition: inline
In-Reply-To: <aec8d6fc050802151125284155@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> I am developing that driver using ieee80211 branch of netdev
> kernel tree, and I am not so confident I do things right using
> new ieee80211 api. I would appreciate any suggestion and review
> of the source code.

please have a look at
http://forge.novell.com/modules/xfmod/cvs/cvsbrowse.php/ieee80211/patches-upstream/
These patches are likely to be merged by Jeff soon (apply using
quilt or use the order in the series file)

Also, you can have a look at
http://forge.novell.com/modules/xfmod/cvs/cvsbrowse.php/ieee80211/patches-netdev/
These patches break a lot of things, but can tell you more about
the ongoing development of the ieee80211 layer.


Regards,

-- 
Jirka Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CR
