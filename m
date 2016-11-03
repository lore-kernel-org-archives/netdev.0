From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 2/2] rtl8xxxu: Fix for bogus data used to determine
 macpower
Date: Thu, 3 Nov 2016 10:43:27 -0500
Message-ID: <73535909-c15e-a8c1-00e3-02b490ab2b1a@lwfinger.net>
References: <cover.1477769750.git.john@zgus.com> <20161030102112.GA5789@cube>
 <wrfjpomidp1v.fsf@redhat.com>
 <CAAye0QN0s1S25tDPNWdM6fsVNaO-wLuSy_RoOSoXeuSMeD4oNA@mail.gmail.com>
 <wrfjzillsan3.fsf@redhat.com> <1478162497.1924.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>,
        Jes Sorensen <Jes.Sorensen@redhat.com>,
        John Heenan <john@zgus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478162497.1924.16.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/03/2016 03:41 AM, Joe Perches wrote:
> On Sun, 2016-10-30 at 19:02 -0400, Jes Sorensen wrote:
>> Code is 80 characters wide, and comments are /* */ never the ugly C++
>> crap.
>
> You might look at the recent Linus Torvalds authored commit
> 5e467652ffef (?printk: re-organize log_output() to be more legible")
> which does both of those: c99 // comments and > 80 columns.
>
> Absolutes are for zealots.

Of course, but who is going to criticize Linus? I have gently chided him when an 
untested patch of his was inserted just before the final release, and broke my 
laptop. At least the bisection was pretty quick. :)

Larry
