From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Draft manpage for recvmmsg [RESEND]
Date: Thu, 29 Sep 2011 06:10:26 +0200
Message-ID: <CAKgNAkiw=vySn4cxeowgi1f-_D0eFAV4kw6G_Ngogqr_KMijqQ@mail.gmail.com>
References: <CAKgNAki0bw4ezSNAYMcg92Gyan049Pg7PyXkcEwJLSiAXOZ_Rg@mail.gmail.com>
 <20110928175213.GK7761@one.firstfloor.org>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Stephan Mueller <stephan.mueller-fwYZOkdEjagAvxtiuMwx3w@public.gmane.org>,
	linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110928175213.GK7761-qrUzlfsMFqo/4alezvVtWx2eb7JE58TQ@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[Restoring CC]

Hi Andi,

On Wed, Sep 28, 2011 at 7:52 PM, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org> wrote:
> On Wed, Sep 28, 2011 at 07:29:00PM +0200, Michael Kerrisk wrote:
>> Hi Andi, Arnaldo,
>>
>> Could you please review the revised recvmmsg.2 man page below.
>>
>> Andi: I need to know what copyright and license to attach to the page
>> before I can release it.
>
> Your original proposal was fine for me.

I didn't make an initial proposal (or I don't recall that I did), but
I suspect you mean the initial proposal on
http://man7.org/linux/man-pages/licenses.html -- that is, the
"Verbatim license". Right?

But please note, I'm also looking for content review on the page,
since I made some notable changes:
* Reworking of some pieces of text
* Added new material on blocking versus non-blocking calls
* Added a more detailed description of how msgvec is updated on return
from the call.
* Added an ERRORS section

Do these changes look okay?

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
