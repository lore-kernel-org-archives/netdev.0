From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Mon, 2 Feb 2015 14:49:37 -0800
Message-ID: <CA+mtBx9RYKY0zDAZEe5Pcc759ysAoXfgwn1rb3PfC92rM-_VvA@mail.gmail.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
	<CA+mtBx90TipY9uJvW2uQfrCYL9JNM9Rk75HzdJPhE0qsdy8dnw@mail.gmail.com>
	<CALnjE+rSXpPftiG4Vw3azkN2s2-Ey6ZcZr9Bv422pOdwrvU=tw@mail.gmail.com>
	<CA+mtBx9yM+C8GeEHOGTHPVxNB3fJd7LQG0RaC3jywrO9_tQ58A@mail.gmail.com>
	<CALnjE+po5gy7g8ftmiNcnrN_gRL9tzCRHNtn=fxUafFikKB1rg@mail.gmail.com>
	<CA+mtBx-v5dvX-OPGeWJb6uwQGhJ5T6iewD83xJGqXb+Ggf+LQw@mail.gmail.com>
	<CAEP_g=-3GXJfawPb4jevkZhqmzTttsO1Rv_2J6GwpG=PR_a-0g@mail.gmail.com>
	<CA+mtBx8mQ4ai3mbY4=HrKjximaEe-+ui2uEqeunQ3kOG=YNBpA@mail.gmail.com>
	<CAEP_g=_rBmDKDM7fjud78YY=HLnf1r3OdcXux=tm55TxG1DFig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:65238 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965084AbbBBWti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 17:49:38 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so20604205iga.1
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 14:49:37 -0800 (PST)
In-Reply-To: <CAEP_g=_rBmDKDM7fjud78YY=HLnf1r3OdcXux=tm55TxG1DFig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 2, 2015 at 12:39 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Feb 2, 2015 at 8:23 AM, Tom Herbert <therbert@google.com> wrote:
>>> I would recommend you take a look at the draft if you haven't already:
>>> http://tools.ietf.org/html/draft-davie-stt-06
>>>
>>> It is currently in the final stages of the RFC publication process.
>>
>> Sorry, but this statement is completely wrong and misleading.
>> According to datatracker this draft has been expired since October,
>> there's been no discussion on it in IETF, and this has not gone to
>> IESG. You cannot say this is an IETF standard nor that it is about to
>> be published as one.  See
>> https://datatracker.ietf.org/doc/draft-davie-stt/ and please read the
>> Internet Standards process in RFC2026.
>>
>> I suggest that you update the draft and post it on both nvo3 and tsvwg
>> so there can be some real discussion on the implications of
>> repurposing an IP protocol number and breaking TCP protocol standards.
>
> Seriously, Tom?
>
> It's currently in the ISE queue to be published as an RFC, which you
> can see in the history in the datatracker link. I didn't say that it
> was being published as a standard, I said RFC. This is the same
> process and status that VXLAN has.. It also was presented in nvo3
> before you started coming.
>
> Please get your facts straight before making accusations.

The draft has not come up before the IESG, I have confirmed that with the ADs.
