From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/5] bonding: keep bond interface carrier off
 until at least one active member
Date: Wed, 21 Jan 2015 00:27:05 -0500
Message-ID: <54BF38A9.7070608@cumulusnetworks.com>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>	<1421423848-414-2-git-send-email-jtoppins@cumulusnetworks.com> <CAE4R7bBzeO5MvL5zS5Piq6Ld2ZbD8smGx8XaJy5SvY7kHbX_Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:35495 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbbAUF1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 00:27:07 -0500
Received: by mail-qc0-f169.google.com with SMTP id b13so15941126qcw.0
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 21:27:07 -0800 (PST)
In-Reply-To: <CAE4R7bBzeO5MvL5zS5Piq6Ld2ZbD8smGx8XaJy5SvY7kHbX_Kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/15 5:15 PM, Scott Feldman wrote:
>
> On Jan 16, 2015 7:57 AM, "Jonathan Toppins"
> <jtoppins@cumulusnetworks.com <mailto:jtoppins@cumulusnetworks.com>> wrote:
>  >
>  > From: Scott Feldman <sfeldma@cumulusnetworks.com
> <mailto:sfeldma@cumulusnetworks.com>>
>
> Hmmmm, this feels a little creepy, sending a patch from my past.  I do
> appreciate the attribution, but I can't ACK or NACK or even comment as
> I've lost the context around this patch.  And I'm afraid I'll break out
> in hives if I look at the bonding code again, so if you don't mind,
> please remove me from this patch.  Thank you.
>

Have removed you for v2 of series, should we consider this a blanket 
statement for any other patches we might be releasing that you had a 
hand in? There were a few ;)
