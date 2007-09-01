From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/5] Net: ath5k, use int as retval
Date: Sat, 01 Sep 2007 22:08:08 +0200
Message-ID: <46D9C6A8.7070600@gmail.com>
References: <2713029743177393055@pripojeni.net> <2440910618305782004@pripojeni.net> <20070830124054.GC5140@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070830124054.GC5140-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville napsal(a):
> On Tue, Aug 28, 2007 at 12:00:09PM -0400, Jiri Slaby wrote:
>> ath5k, use int as retval
>>
>> Convert some functions to return int and proper negative return value on
>> error as we are used to.
> 
> Since I didn't apply 1/5, this one didn't apply either.  It seems
> fine overall, so if you rediff I'll be happy to apply.

Ok, I'll do it, thanks,
-- 
http://www.fi.muni.cz/~xslaby/            Jiri Slaby
faculty of informatics, masaryk university, brno, cz
