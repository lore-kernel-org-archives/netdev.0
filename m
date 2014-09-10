From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Wed, 10 Sep 2014 13:36:50 +0200
Message-ID: <541037D2.7060007@gmail.com>
References: <20140213201421.GJ22203@tuxdriver.com>	<1397581703.8212.5.camel@x220>	<CAHNKnsQQ42-XnXrubHAy4PF3H2ynbGDdSMP7MvDS_1aRozYF=A@mail.gmail.com>	<1403087119.1984.93.camel@x220>	<CAHNKnsSfaT7xC5_wv=TrGLEQ2pjC91Q1XG891_n64OuR0fA9Jg@mail.gmail.com>	<1403091974.1984.102.camel@x220>	<1409911856.7832.9.camel@x220>	<CAHNKnsRipRHicKOUW4dCutD1-sUG6qPnP2QuOveH_t1MFX9XgQ@mail.gmail.com>	<1409916824.7832.20.camel@x220>	<CAHNKnsQ1gt=DRBTd9Q9yos1idqmXMepEPvhm8a7unP-whzNAgg@mail.gmail.com>	<20140909182734.GJ29412@tuxdriver.com> <CAHNKnsQ8G3ZFHshq7wOqex1J6DbVD5uHVAyvs+aDC2Znk5zWww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>,
	Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>,
	Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>,
	Jonathan Bither <jonbither-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	ath5k-devel-juf53994utBLZpfksSYvnA@public.gmane.org, open-5/S+JYg5SzeELgA04lAiVw@public.gmane.org,
	"list-5/S+JYg5SzeELgA04lAiVw@public.gmane.org:NETWORKING DRIVERS" <list-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	"antonynpavlov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <antonynpavlov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	OpenWrt Development List <openwrt-devel-ZwoEplunGu0+xA9t4nZiwti2O/JbrIOy@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"list-5/S+JYg5SzeELgA04lAiVw@public.gmane.org:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHNKnsQ8G3ZFHshq7wOqex1J6DbVD5uHVAyvs+aDC2Znk5zWww-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/10/2014, 12:33 PM, Sergey Ryazanov wrote:
> 2014-09-09 22:27 GMT+04:00, John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>:
>> On Fri, Sep 05, 2014 at 04:02:10PM +0400, Sergey Ryazanov wrote:
>>> 2014-09-05 15:33 GMT+04:00 Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>:
>>>> Hi Sergey,
>>>>
>>>> On Fri, 2014-09-05 at 15:12 +0400, Sergey Ryazanov wrote:
>>>>> 2014-09-05 14:10 GMT+04:00, Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>:
>>>>>> On Wed, 2014-06-18 at 13:46 +0200, Paul Bolle wrote:
>>>>>>> Having this conversation every rc1 is getting a bit silly. Could
>>>>>>> Jiri
>>>>>>> e.a. perhaps set some specific deadline for ATHEROS_AR231X to be
>>>>>>> submitted?
>>>>>>
>>>>>> I waited until rc3. Have you seen any activity on this front? If
>>>>>> not,
>>>>>> should I resend the patch that removes the code in mainline that
>>>>>> depends
>>>>>> on ATHEROS_AR231X (ie, AHB bus support)?
>>>>>>
>>>>> Recent activity always could be found in [1]. Now I finish another one
>>>>> round of cleanups and have a plan to fix several things (you can
>>>>> always find something that you really want to improve). But if you
>>>>> insist I could immediately switch to "send upstream" mode. And seems
>>>>> that this would be better approach.
>>>>>
>>>>> 1. https://dev.openwrt.org/log/trunk/target/linux/atheros
>>>>
>>>> And where can the related PULL requests or patch submissions be found?
>>>>
>>> I have not sent patches yet, since I thought that it would be easier
>>> to cleanup them in openwrt tree and then send them upstream.
>>
>> That excuse has worn a bit thin.  Perhaps Paul should repost his
>> removal and you can add a revert to the start of your patch series?
>>
> As for me, I do not like such flapping

Agreed in case what you have is in a good enough shape. You (and also
others) can still clean up the code in upstream too. So, if it is
mergeable, send it for upstream inclusion now, otherwise I am all for
John to apply the Paul's patch. The unused code has been a way too long
in the tree now.

thanks,
-- 
js
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
