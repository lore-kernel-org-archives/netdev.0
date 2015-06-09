From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Tue, 9 Jun 2015 10:14:53 -0700
Message-ID: <CAJmoNQH33yGEjcRDxzxYPScttdMo1FZSQfT0yOOGyK8yXKBeDg@mail.gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
	<5576AAD2.8010405@6wind.com>
	<5576F652.4090903@gmail.com>
	<5576FE6A.7000703@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Ahern <dsahern@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jon Toppins <jtoppins@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37340 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbbFIROy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 13:14:54 -0400
Received: by wifx6 with SMTP id x6so23649889wif.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 10:14:53 -0700 (PDT)
In-Reply-To: <5576FE6A.7000703@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 9, 2015 at 7:55 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 09/06/2015 16:21, David Ahern a =C3=A9crit :
>>
>> Hi Nicolas:
>>
>> On 6/9/15 2:58 AM, Nicolas Dichtel wrote:
>>>
>>> I'm not really in favor of the name 'vrf'. This term is very
>>> controversial and
>>> having a consensus of what is/contains a 'vrf' is quite impossible.
>>> There was already a lot of discussions about this topic on quagga m=
l
>>> that show
>>> that everybody has a different opinion about this term ;-)
>>
>>
>> Are you referring to this thread?
>> https://lists.quagga.net/pipermail/quagga-dev/2014-November/011795.h=
tml
>
> No, there were recent discussions on quagga about that subject. Here =
is some
> non-exhaustive pointers:
> https://lists.quagga.net/pipermail/quagga-dev/2015-May/012581.html
> https://lists.quagga.net/pipermail/quagga-dev/2015-May/012630.html
> https://lists.quagga.net/pipermail/quagga-dev/2015-June/012715.html
>
> Note the last pointer also explains why it was called MRF by Cumulus.
>
>

Agreed, I used the term VRF for this series to make sure we had the
right context, but clearly MRF is a term we are happier to use ..

> Regards,
> Nicolas
