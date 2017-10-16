From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Mon, 16 Oct 2017 18:26:13 +0200
Message-ID: <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl>
References: <1507121766.30720.4.camel@cohaesio.com>
 <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com>
 <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
 <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
 <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: Pavlos Parissis <pavlos.parissis@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:42632 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754077AbdJPQ0N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 12:26:13 -0400
In-Reply-To: <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-10-16 o 13:20, Pavlos Parissis pisze:
> On 15/10/2017 02:58 πμ, Alexander Duyck wrote:
>> Hi Pawel,
>>
>> To clarify is that Dave Miller's tree or Linus's that you are talking
>> about? If it is Dave's tree how long ago was it you pulled it since I
>> think the fix was just pushed by Jeff Kirsher a few days ago.
>>
>> The issue should be fixed in the following commit:
>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/drivers/net/ethernet/intel/i40e/i40e_txrx.c?id=2b9478ffc550f17c6cd8c69057234e91150f5972
>>
>
> Do you know when it is going to be available on net-next and linux-stable repos?
>
> Cheers,
> Pavlos
>
>
I will make some tests today night with "net" git tree where this patch 
is included.
Starting from 0:00 CET
:)
