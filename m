From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Thu, 21 Apr 2016 16:45:28 +0300
Message-ID: <CAJ3xEMjreiZ_gQm66ji4JKnnKDX5bpEmgBhULc8hb3wHLvvS4g@mail.gmail.com>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
	<20160419182212.GA8441@infradead.org>
	<571785A5.5040306@codeaurora.org>
	<CAKHjkjmYNLABO10V1DZQmZ_zczjbfDZU0TDPHoMmv_1FMi9_gA@mail.gmail.com>
	<CAJ3xEMiZ-L5OSogx_3fTSOt-chvYJw6ANtbxYJi5TFR-_H4U-g@mail.gmail.com>
	<20160421133903.GA19633@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Abramovsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eran Ben Elisha <eranlinuxmellanox-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160421133903.GA19633-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 21, 2016 at 4:39 PM, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> wrote:
> On Thu, Apr 21, 2016 at 04:37:42PM +0300, Or Gerlitz wrote:
>> On Wed, Apr 20, 2016 at 9:40 PM, Eran Ben Elisha
>> <eranlinuxmellanox-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> >> It is been 1.5 years since I reported the problem. We came up with three
>> >> different solutions this week. I'd like to see a version of the solution
>> >> to get merged until Mellanox comes up with a better solution with another
>> >> patch. My proposal is to use this one.
>>
>> > We will post our suggestion here in the following days.
>>
>> To update, Haggai A from our driver team is working on a patch. He is
>> providing a copy for
>> testing over ARM to the folks that reported on the problem and will
>> post it here early next week.
>
> Any chance you could give feedback to the patch I posted this week?


I missed your patch, looking on it now down this thread, I think
Haggai's patch is very much similar to yours, he's also touching some
more code in the IB driver.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
