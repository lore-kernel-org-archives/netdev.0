From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-01
Date: Sat, 2 Aug 2008 12:16:47 +0300
Message-ID: <1ba2fa240808020216i320e97e6j9510597f5b3daf83@mail.gmail.com>
References: <20080801205830.GA10071@tuxdriver.com>
	 <1ba2fa240808011443u1a5553fpfca046f047773217@mail.gmail.com>
	 <20080802032946.GA29921@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080802032946.GA29921-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 2, 2008 at 6:29 AM, John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> On Sat, Aug 02, 2008 at 12:43:32AM +0300, Tomas Winkler wrote:
>> On Fri, Aug 1, 2008 at 11:58 PM, John W. Linville
>> <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
>> > Dave,
>> >
>> > Another big batch of wireless fixes for 2.6.27.  The ath5k series is
>> > more than fixes, but I included it because it enables new ath5k
>> > hardware.  (The ath5k.h changes in particular are documentation cleanups
>> > for registers based on info gleaned from the newly posted ath9k driver.)
>> > The others patches are fixes, some more obvious than others. :-)
>> >
>> > Let me know if there are any problems!
>>
>> All the iwlwifi patches should go up otherwise the support for 5000 HW
>> will be incomplete.
>
> Then they should have been posted before 2.6.26 was released...

Unfortunately I cannot align development progress with kernel
releases. This cat is not tatural for the driver. But this time all
the patches that went out after 2.6.26 are bug fixes maybe except
module renaming patches. There are no new features added all we do is
cleaning up our bug reports.
Hope we won't end up with not working driver like in 2.6.26.
Tomas

> --
> John W. Linville
> linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
