From: "Udayan Singh" <udayan.singh@gmail.com>
Subject: Re: [Info]d80211 : Understanding d80211
Date: Sat, 4 Nov 2006 21:11:06 +0530
Message-ID: <d9a09df00611040741s7612c79fu4122faf64da48a21@mail.gmail.com>
References: <d9a09df00611031943n41cf27beu566383b0e1c96197@mail.gmail.com>
	 <454C13FF.6070902@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, udayan.singh@tcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:49283 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S965515AbWKDPlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Nov 2006 10:41:17 -0500
Received: by wx-out-0506.google.com with SMTP id s14so663713wxc
        for <netdev@vger.kernel.org>; Sat, 04 Nov 2006 07:41:16 -0800 (PST)
To: "Larry Finger" <Larry.Finger@lwfinger.net>
In-Reply-To: <454C13FF.6070902@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/4/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> Udayan Singh wrote:
> > Hi,
> >
> > I wanted to understand the code of d80211 (thanks to James Ketrenos
> > for the info he provided) and also work in it.
> >
> > I found that I can get the latest patches regarding the same from :
> >
> > http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/
>
> Wireless-2.6 contains the developmental version of wireless code _NOT_ using
> d80211. The d80211
> development version is at
> git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git
> and must be downloaded with git, not ftp or http.

ok.


> > Any docs that I can read through that you would recommend from where I
> > can start up ?
>
> Only the code AFAIK.
>

referring to the standards might  be good i.e. 802.11 standards ??

I intend to work in the manner:

1. There are quite many standards that have already been implemented
e.g. 802.11a/b/g in the kernel (here wireless-dev). If there is a new
standard wrt. 802.11x coming in, then I can work on same.

2. Work on an already implemented standard and try to add a missing
feaature into it.

Kindly let me know your opinions.

tia,
Udayan

>
> Larry
>
>
