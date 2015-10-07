From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv4 net 1/6] openvswitch: Fix typos in CT headers
Date: Wed, 7 Oct 2015 09:12:19 -0700
Message-ID: <CANr6G5xEYOz9HuA-=frOcr=qaV7LtB65gdKy+jX+MwGUjdosDw@mail.gmail.com>
References: <1444154401-18029-1-git-send-email-joestringer@nicira.com>
 <1444154401-18029-2-git-send-email-joestringer@nicira.com> <56151F1B.6080207@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:33098 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833AbbJGQMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 12:12:39 -0400
Received: by ykft14 with SMTP id t14so22165954ykf.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 09:12:38 -0700 (PDT)
In-Reply-To: <56151F1B.6080207@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 October 2015 at 06:33, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 10/6/2015 8:59 PM, Joe Stringer wrote:
>
>> These comments hadn't caught up to their implementations, fix them.
>>
>> Fixes: 7f8a436eaa2c "openvswitch: Add conntrack action"
>
>
>    Sigh. Please see Documentation/SubmittingPatches. It should be:
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")

Sorry about that. I've amended my gitconfig to avoid this in future.
