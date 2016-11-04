From: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] rtl8xxxu: Fix for bogus data used to determine macpower
Date: Fri, 04 Nov 2016 09:56:00 -0400
Message-ID: <wrfjshr7mjrj.fsf@redhat.com>
References: <cover.1477769750.git.john@zgus.com> <20161030102112.GA5789@cube>
        <wrfjpomidp1v.fsf@redhat.com>
        <CAAye0QN0s1S25tDPNWdM6fsVNaO-wLuSy_RoOSoXeuSMeD4oNA@mail.gmail.com>
        <wrfjzillsan3.fsf@redhat.com> <1478162497.1924.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: John Heenan <john-AMlJbUfTsso@public.gmane.org>, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1478162497.1924.16.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> (Joe Perches's message of
        "Thu, 03 Nov 2016 01:41:37 -0700")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> writes:
> On Sun, 2016-10-30 at 19:02 -0400, Jes Sorensen wrote:
>> Code is 80 characters wide, and comments are /* */ never the ugly C++
>> crap.
>
> You might look at the recent Linus Torvalds authored commit
> 5e467652ffef (?printk: re-organize log_output() to be more legible")
> which does both of those: c99 // comments and > 80 columns.
>
> Absolutes are for zealots.

What Linus does in his code, is totally up to him. What I pull into the
driver that *I* maintain, is up to me. It is perfectly normal to expect
submitters to respect the coding style of the piece of code they are
trying to edit.

Jes
