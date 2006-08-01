From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Tue, 1 Aug 2006 16:25:05 +0200
Message-ID: <a32f33a40608010725m247304a5vda49207c8f36cf62@mail.gmail.com>
References: <200607270037.22384.flamingice@sourmilk.net>
	 <20060731203113.GG10138@tuxdriver.com>
	 <200607311351.35757.flamingice@sourmilk.net>
	 <20060801095650.GA6831@infradead.org>
	 <20060801122142.GB29208@tuxdriver.com>
	 <20060801155837.4c3210aa@griffin.suse.cz>
	 <20060801140720.GC29208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>,
	"Christoph Hellwig" <hch@infradead.org>,
	"Michael Wu" <flamingice@sourmilk.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:15255 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751610AbWHAOZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 10:25:06 -0400
Received: by py-out-1112.google.com with SMTP id t32so1205353pyc
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2006 07:25:05 -0700 (PDT)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801140720.GC29208@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > Do you have a plan when you will merge rt2x00 patches so I can apply
> > Michael's renaming patch(es) without risk of conflicts?
>
> Working on it ~now.  I hit a snag in that Ivo's patches seem to rely on
> his radio button patch, which I had ignored until now.  I'll probably
> pull that in this morning (or figure-out how to not need it) and get
> something pushed to wireless-dev sometime today.

Ehm, that should not have happened. The rt2x00 version I had send as patches
had the radio button integrated as they had been in wireless-dev already.
The patch to convert it to the rfkill driver is one of the patches
I'll send later.

Ivo
