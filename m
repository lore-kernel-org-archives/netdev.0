From: "Bob Copeland" <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-10-29
Date: Wed, 29 Oct 2008 21:19:01 -0400
Message-ID: <b6c5339f0810291819ld7d6043k56b11128bc6252cb@mail.gmail.com>
References: <20081029231855.GD3485@tuxdriver.com>
	 <20081029162324.28f5864d@infradead.org>
	 <20081029233350.GE3485@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Arjan van de Ven" <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081029233350.GE3485-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2008 at 7:33 PM, John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> On Wed, Oct 29, 2008 at 04:23:24PM -0700, Arjan van de Ven wrote:
>> On Wed, 29 Oct 2008 19:18:55 -0400
>> "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
>> it seems to have added a few WARN_ON()s which now end up at the top of
>> the list .. are these known or should I spend some time writing reports
>> for netdev ?

Pavel Roskin posted one such WARN_ON to ath5k-devel a few days ago.
Seems related to setup of the rate tables, but I haven't reproduced it
here yet.  I'll see if he has more info...

-- 
Bob Copeland %% www.bobcopeland.com
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
