From: Jesse Gross <jesse@nicira.com>
Subject: Re: Where are OVS VXLAN patches?
Date: Fri, 16 Aug 2013 08:58:15 -0700
Message-ID: <CAEP_g=9+aLyfY_3TaLkdHeKJGRUHtNFcjk=0w-DEUQ7Q_iHjGw@mail.gmail.com>
References: <1376291275.17589.18.camel@cr0> <CAEP_g=-JQUZaLUhkMWQ6p8iYn8jqb_0tZOq=x+kv0Xip3dUA7A@mail.gmail.com>
 <1376370988.13583.6.camel@cr0> <1376615540.2934.3.camel@cr0>
 <CAOaVG16Vx11DV4gxfSf2f0BceOk1y+aP6rtz-_h9b0Ckp0r2Jw@mail.gmail.com> <1376628625.2934.57.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:53363 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751820Ab3HPP6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 11:58:36 -0400
Received: by mail-la0-f45.google.com with SMTP id eh20so1611122lab.18
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 08:58:35 -0700 (PDT)
In-Reply-To: <1376628625.2934.57.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 9:50 PM, Cong Wang <amwang@redhat.com> wrote:
> (Re-adding netdev and davem...)
>
> On Thu, 2013-08-15 at 21:33 -0700, Stephen Hemminger wrote:
>> Send them to netdev. The vxlan-next tree was temporary when there were
>> 3 people working on VXLAN at
>> same time (Pravin, ong, and me). I see no point in keeping a separate
>> tree over the long term.
>>
>
> I agree. There is some misunderstanding between you and David on taking
> these patches. :)

Thanks for following up Cong.

David, if you just want to take the whole series at this point, there
shouldn't be any conflicts on my end and that way we can finally get
this in.
