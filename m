From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 18:00:34 -0800
Message-ID: <CAL1RGDWzVRc4jFtsKUC6FGrdAWn3_OThXpbChCETCR8UCrwDDA@mail.gmail.com>
References: <alpine.WNT.2.00.1111291027320.1036@TSI> <1322589661.2596.2.camel@edumazet-laptop>
 <1322599437.2596.10.camel@edumazet-laptop> <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com>
 <1322599991.2596.11.camel@edumazet-laptop> <alpine.WNT.2.00.1111291359290.1036@TSI>
 <1322601444.2596.21.camel@edumazet-laptop> <1322602283.2596.25.camel@edumazet-laptop>
 <CAL1RGDUcYJKBSCthTL1AFgpRvzjoaEpHjGFhratKP-98ufRKnw@mail.gmail.com> <alpine.WNT.2.00.1111291815410.1288@TSI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.WNT.2.00.1111291815410.1288@TSI>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2011 at 5:17 PM, Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org> wrote:
> On Tue, 29 Nov 2011, Roland Dreier wrote:
>>
>> On Tue, Nov 29, 2011 at 1:31 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> wrote:
>>>
>>> Here is the result of this audit, please double check and test it, I
>>> only compiled this.
>
>> Thanks Eric... I'll queue this up and send it on once we get a good
>> report from Marc.
>
> I can confirm that Eric's patch, retrofitted to 3.1.3, fixes the problem.

Oh... the problem was already in 3.1?

I'll tag the patch for stable too.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
