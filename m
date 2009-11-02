From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Mon, 2 Nov 2009 12:01:15 -0500
Message-ID: <20091102170114.GE14046@tuxdriver.com>
References: <1256886023.3555.5.camel@johannes.local> <20091030110616.GB6150@ff.dom.local> <20091030150223.GA2586@tuxdriver.com> <20091102091038.GA9044@elte.hu> <1257153807.3555.173.camel@johannes.local> <20091102100702.GA16963@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091102100702.GA16963-X9Un+BFzKDI@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 02, 2009 at 11:07:02AM +0100, Ingo Molnar wrote:
> 
> * Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> 
> > On Mon, 2009-11-02 at 10:10 +0100, Ingo Molnar wrote:
> > 
> > > So i have read the thread you and Bartlomiej referenced:
> > > 
> > >     http://lkml.org/lkml/2009/10/17/81
> > > 
> > > ... and my understanding of that discussion is very different from 
> > > yours. Here is my annotated history of the beginnings of that 
> > > discussion:
> > 
> > [snip]
> > 
> > You shouldn't ignore all previous interaction between Bart and us -- 
> > which wasn't pretty: http://thread.gmane.org/gmane.linux.kernel/901892
> 
> I have seen that exchange too - here's the lkml.org link for those who 
> like the lkml.org format:
> 
>    http://lkml.org/lkml/2009/10/13/186
> 
> And i can see no supporting fact here either, for the (very serious) 
> accusation launched by John Linville, that Bartlomiej is 'petty, 
> whining, indignant'. In my reading he is the opposite of that, even in 
> this second thread you point out.

Again, you seem to be very generous to Bartlomiej and very critical of
the rest of us in your readings.

> So, no matter how much you disagree about the code and its direction, 
> please either back up your assertion with specific links to a pattern of 
> misbehavior or apologize for the ad-hominen attacks against Bartlomiej.

His behavior is evident in the threads you cited.  How you do not
see that is a mystery.

> > Of course we were biased when he came around with that petty code 
> > duplication argument, since it seemed to support only his agenda of 
> > working only with the staging drivers.
> 
> Why do you think that disagreeing in the past gives you the right to get 
> into ad-hominens? You should concentrate on the code and on the 
> technical side, not on the person making the argument.
> 
> Also, why do you characterise a code duplication argument as 'petty'?

Did you actually look at the thread?  Or did you simply here "code
duplication" and run with it?
 
> Bloat and unnecessary technical forking is the #1 enemy of Linux. 
> Integrating code and infrastructure is the #1 strength of Linux.
> 
> Upstream subsystems/drivers running away with their private 
> implementations has its clear costs:

...which has nothing to do with the case at hand.  Please do not
perpetuate this myth.  If anything, your argument applies far more
to the drivers in staging that Bartlomiej has focused his attention
upon until recently.

<snip>

> [ I dont know why drivers/staging/ is even an argument here - he argued
>   about the technical qualities of a new upstream driver, not about a
>   staging driver. Upstream drivers are to be held to higher standards,
>   _especially_ now that we can isolate not-clean-enough-yet drivers into
>   drivers/staging/, without hurting users. ]

If you had been keeping-up, you would realize that Bartlomiej is upset
about our criticisms of the Ralink drivers in staging.  That would seem
to be the reason he has made himself such an irritant in linux-wireless
over the past few weeks.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
