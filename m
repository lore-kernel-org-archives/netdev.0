From: "Justin Mattock" <justinmattock@gmail.com>
Subject: Re: pull request: wireless-2.6 2008-08-04
Date: Mon, 4 Aug 2008 16:38:52 -0700
Message-ID: <dd18b0c30808041638qcc67ab8xe5247fa8a1bbd36e@mail.gmail.com>
References: <20080804193753.GA30345@tuxdriver.com>
	 <1217882288.7819.19.camel@californication>
	 <20080804204558.GA5866@tuxdriver.com>
	 <1217886123.7819.23.camel@californication>
	 <20080804215439.GA9658@tuxdriver.com>
	 <1217889426.7819.26.camel@californication>
	 <43e72e890808041545y1b1727c1t90db35721a9c9d8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Marcel Holtmann" <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:22116 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753960AbYHDXix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 19:38:53 -0400
Received: by an-out-0708.google.com with SMTP id d40so367823and.103
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2008 16:38:52 -0700 (PDT)
In-Reply-To: <43e72e890808041545y1b1727c1t90db35721a9c9d8d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 4, 2008 at 3:45 PM, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> On Mon, Aug 4, 2008 at 3:37 PM, Marcel Holtmann <marcel@holtmann.org> wrote:
>> Hi John,
>>
>>> > > > > Luis R. Rodriguez (4):
>>> > > > >       list.h: Add list_splice_tail() and list_splice_tail_init()
>>> > > > >       list.h: add list_cut_position()
>>> > > >
>>> > > > have these two changes got reviewed on LKML? I don't see any ACKs for it
>>> > > > in the commit message.
>>> > >
>>> > > Hmmm...no.  I thought the original patches had been copied to
>>> > > linux-kernel, but it looks like that is not the case.
>>> > >
>>> > > The original patches are archived here:
>>> > >
>>> > >   http://marc.info/?l=linux-wireless&m=121783421908441&w=2
>>> > >
>>> > >   http://marc.info/?l=linux-wireless&m=121783422008445&w=2
>>> > >
>>> > > What problems do you see with them?
>>> >
>>> > I don't see a problem with these patches, but they should at least be
>>> > reviewed on LKML once. Changes to core kernel infrastructure should not
>>> > be merged silently via subsystem trees without any kind of ACKs.
>>>
>>> Yes, fine.  That wasn't my intent. :-)  The patches were originally
>>> posted about two weeks ago, too bad that didn't actually go to
>>> linux-kernel. :-(
>>
>> just post them to LKML (or let Luis do it) so they get reviewed. I
>> really don't see an issue with them, but that is only me.
>
> I'll repost those specific patches and add lkml.
>
>  Luis
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

I must be honest, I am really excited
to see ath9k, finally an in kernel module
for my wireless card.

regards;

-- 
Justin P. Mattock
