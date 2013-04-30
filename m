From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH net-next] Revert "bnx2x: allow nvram test to run when
 device is down"
Date: Tue, 30 Apr 2013 23:28:50 +0300
Message-ID: <CAM8tLiMy2O-4borrMR69WTh7KsdN-oFZTwx0dUy9_7hS=QBbRw@mail.gmail.com>
References: <1367314447-10518-1-git-send-email-dmitry@broadcom.com>
	<20130430.154916.289965268165509683.davem@davemloft.net>
	<5180250B.3010703@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:60657 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932813Ab3D3U2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 16:28:51 -0400
Received: by mail-vb0-f46.google.com with SMTP id 10so770725vbe.19
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 13:28:51 -0700 (PDT)
In-Reply-To: <5180250B.3010703@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 11:09 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 04/30/2013 11:49 PM, David Miller wrote:
>
>>
>>> This reverts commit d2d2d87dfd1a25ee270994c5b9e3eb4690428d32.
>>
>> Please refer to commits in the following format:
>>
>> ${SHA_ID} ("Commit message header line.")
>
>
>    David, this is a standard revert changelog format, reverted commit's
> summary is in the subject.
>
> WBR, Sergei
>

I think both of then the ID and the message will appear in the log once applied.
Probably we want to fix git-revert format. Anyway sent v2.
