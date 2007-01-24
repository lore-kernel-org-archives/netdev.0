From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: dscape doesn't auto associate
Date: Tue, 23 Jan 2007 21:08:34 -0500
Message-ID: <9e4733910701231808l451453ak16de4d1745b08209@mail.gmail.com>
References: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com>
	 <200701231843.05902.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:34513 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965616AbXAXCIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 21:08:35 -0500
Received: by nz-out-0506.google.com with SMTP id s1so34601nze
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 18:08:34 -0800 (PST)
To: "Michael Wu" <flamingice@sourmilk.net>
In-Reply-To: <200701231843.05902.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/23/07, Michael Wu <flamingice@sourmilk.net> wrote:
> On Tuesday 23 January 2007 18:23, Jon Smirl wrote:
> > I have to manually associate the dscape stack with my AP. Is this way
> > the code is supposed to work? Everything works ok after the manual
> > association.
> >
> It's suppose to work with wpa_supplicant which sets every parameter.
> NetworkManager uses wpa_supplicant so configuration can be pretty easy.

Speaking of wpa_supplicant I've been unable to get to main site
according to wikipedia for over a week. Has this project moved
elsewhere?

http://hostap.epitest.fi/wpa_supplicant

> If you really want to manually associate, set the channel, (e)ssid, and
> encryption (if any) in any order, and then set the bssid (ap) last. There
> will be patches to allow association by just setting the SSID for backwards
> compatibility with configuration scripts.
>
> -Michael Wu
>
>
>


-- 
Jon Smirl
jonsmirl@gmail.com
