From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2008-07-14
Date: Tue, 15 Jul 2008 09:24:31 -0700
Message-ID: <20080715092431.d288d0e8.randy.dunlap@oracle.com>
References: <20080714192302.GA2541@tuxdriver.com>
	<20080714132918.30a1794f.randy.dunlap@oracle.com>
	<20080715134849.GA24361@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080715134849.GA24361-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2008 09:48:49 -0400 John W. Linville wrote:

> On Mon, Jul 14, 2008 at 01:29:18PM -0700, Randy Dunlap wrote:
> > On Mon, 14 Jul 2008 15:23:02 -0400 John W. Linville wrote:
> > 
> > > Dave,
> > > 
> > > Here is one last(?) round of miscellaneous patches I hope to get into
> > > 2.6.27.  There are mostly driver updates, including a sizable iwlwifi
> > > set of changes.
> > > 
> > > Please let me know if there are problems!
> > 
> > Hi,
> > Dare I ask what happened to the mac80211 kernel-doc patch?
> > 
> > Thanks,
> > ~Randy
> 
> commit 6ef307bc561911c8cdda98ef3896b5982b602a43
> Author: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Date:   Thu Jul 3 13:52:18 2008 -0700
> 
>     mac80211: fix lots of kernel-doc
>     
>     Fix more than 50 kernel-doc warnings in ieee80211/mac80211 kernel-doc notati
>     Fix a few typos also.
>     
>     Note: Some fields are marked as TBD and need to have their description
>     corrected.
>     
>     Signed-off-by: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>     Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>


Yes, that's in the wireless-next-2.6 git tree:
http://git.kernel.org/?p=linux/kernel/git/linville/wireless-next-2.6.git;a=commit;h=6ef307bc561911c8cdda98ef3896b5982b602a43

and this was a pull request, possibly even the last(?) pull, for wireless-next-2.6
for 2.6.27, according to the email intro.  So please tell me what I can
expect for this mac80211 kernel-doc patch.  Thanks.

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
