From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: Will RFC1146 (tcp alternative checksum options) be implemented in Linux tcp stack ?
Date: Tue, 16 Oct 2007 14:57:56 +1300
Message-ID: <5640c7e00710151857p12a19bf2radf1972835b811d@mail.gmail.com>
References: <887901.30138.qm@web55205.mail.re4.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Yanping Du" <ypdu2001@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:1962 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467AbXJPB55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 21:57:57 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2202071wah
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 18:57:57 -0700 (PDT)
In-Reply-To: <887901.30138.qm@web55205.mail.re4.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/07, Yanping Du <ypdu2001@yahoo.com> wrote:
> Hi,
>
>   We found the standard 16-bit tcp checksum is not
> strong enough in some cases. Is there any roadmap on
> implementing RFC1146 (tcp alternative checksum
> options) in Linux tcp stack ? If yes, how soon will
> that be in ?
>
> Please kindly copy reply to my email address as I've
> not subscribed the netdev@ mailing list at present.
>
>   http://www.faqs.org/rfcs/rfc1146.html
>
> Thanks!
> -Yanping
>
>
Yanping,

The way that features get added to Linux is that someone interested
writes it. You can't just say - is this on the roadmap, as there is no
roadmap really!

I have been interested in network features from an academic point of
view and so I wrote what I needed (along with others) and that was
added to the Linux kernel.

So have a go at implementing it if you consider it important and come
back here with some patches. Then others will help review it until the
patches are good.

I will let others comment on whether the checksums are a good idea or not.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
