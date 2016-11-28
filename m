From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 0/4] Fix -Wunused-but-set-variable in net/mac80211/
Date: Mon, 28 Nov 2016 14:15:42 +0100
Message-ID: <1480338942.8107.38.camel@sipsolutions.net>
References: <cover.1479962513.git.kirtika@chromium.org>
         (sfid-20161124_054535_974361_648CC55D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Marek Kwaczynski <marek.kwaczynski-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        David Spinadel <david.spinadel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Alexander Bondar <alexander.bondar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1479962513.git.kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> (sfid-20161124_054535_974361_648CC55D)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-11-23 at 20:45 -0800, Kirtika Ruchandani wrote:
> This patchset is part of the effort led by Arnd Bergmann to clean up
> warnings in the kernel. This and following patchsets will focus on
> "-Wunused-but-set-variable" as it among the noisier ones. These were
> found compiling with W=1.

All four applied, thanks.

johannes
