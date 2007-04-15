From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: {Spam?} Re: {Spam?} [PATCH] NET: Remove obsolete traffic shaper code.
Date: Sun, 15 Apr 2007 14:48:40 +1200
Message-ID: <5640c7e00704141948n5f82cd8fl64092c720954175f@mail.gmail.com>
References: <Pine.LNX.4.64.0704141925310.22138@localhost.localdomain>
	 <5640c7e00704141646k44334de9g99dc509bf96bac5f@mail.gmail.com>
	 <Pine.LNX.4.64.0704141959190.22316@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "Adrian Bunk" <bunk@stusta.de>
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752064AbXDOCsm@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0704141959190.22316@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/15/07, Robert P. J. Day <rpjday@mindspring.com> wrote:
> in fact, according to this:
>
> http://lkml.org/lkml/2006/1/13/139
>
> that notice was put in the feature removal file well over a year ago,
> during 2.6.15.  so that would seem to be more than adequate time for
> everyone to prepare for it.  but it must have been deleted from that
> file since then as well.

Yes and that was never merged and so was resent on January 19th, 2006:
http://www.nabble.com/-2.6-patch--schedule-SHAPER-for-removal-t949871.html

At that point people debated about it being too short notice and the
patch never went in.

I therefore think we can't just remove with NO notice.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
