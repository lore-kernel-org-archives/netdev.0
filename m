From: Hong zhi guo <honkiko@gmail.com>
Subject: Re: [PATCH net-next] openvswitch: correct an invalid BUG_ON
Date: Thu, 28 Mar 2013 00:58:46 +0800
Message-ID: <CAA7+ByV3Otp9EKi0wvVa2bP9NR-GFt1zOSnFvkwOjWhcwCQSog@mail.gmail.com>
References: <1364388077-30480-1-git-send-email-honkiko@gmail.com>
	<CAEP_g=-=mv=ZOR17hfDYAq_zSEQzyetG0n=sJjTrkOjLTHLt8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f43.google.com ([209.85.212.43]:50211 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886Ab3C0Q6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 12:58:47 -0400
Received: by mail-vb0-f43.google.com with SMTP id fs19so5405435vbb.30
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 09:58:46 -0700 (PDT)
In-Reply-To: <CAEP_g=-=mv=ZOR17hfDYAq_zSEQzyetG0n=sJjTrkOjLTHLt8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your review comments. I re-patched according to your
comments. Please help to review it. Thanks.

On Wed, Mar 27, 2013 at 11:19 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Wed, Mar 27, 2013 at 5:41 AM, Hong Zhiguo <honkiko@gmail.com> wrote:
>> table->count is uint32_t
>>
>> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
>
> Applied, thanks.



-- 
best regards
Hong Zhiguo
