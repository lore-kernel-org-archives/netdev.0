From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] rtl8xxxu: Fix for bogus data used to determine
 macpower
Date: Thu, 03 Nov 2016 01:41:37 -0700
Message-ID: <1478162497.1924.16.camel@perches.com>
References: <cover.1477769750.git.john@zgus.com>
         <20161030102112.GA5789@cube> <wrfjpomidp1v.fsf@redhat.com>
         <CAAye0QN0s1S25tDPNWdM6fsVNaO-wLuSy_RoOSoXeuSMeD4oNA@mail.gmail.com>
         <wrfjzillsan3.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>, John Heenan <john@zgus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <wrfjzillsan3.fsf@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-10-30 at 19:02 -0400, Jes Sorensen wrote:
> Code is 80 characters wide, and comments are /* */ never the ugly C++
> crap.

You might look at the recent Linus Torvalds authored commit
5e467652ffef (?printk: re-organize log_output() to be more legible")
which does both of those: c99 // comments and > 80 columns.

Absolutes are for zealots.
