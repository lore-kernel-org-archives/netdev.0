From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.17-mm4
Date: Thu, 29 Jun 2006 23:41:43 +0200
Message-ID: <6bffcb0e0606291441u4f90e4b2ieb0cdf38fc29d486@mail.gmail.com>
References: <20060629013643.4b47e8bd.akpm@osdl.org>
	 <6bffcb0e0606291339s69a16bc5ie108c0b8d4e29ed6@mail.gmail.com>
	 <20060629204330.GC13619@redhat.com>
	 <6bffcb0e0606291346s64530db4g1c9c33da9cf34e73@mail.gmail.com>
	 <20060629135826.20328067.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:3208 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932801AbWF2Vlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 17:41:44 -0400
Received: by py-out-1112.google.com with SMTP id b36so440523pyb
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:41:44 -0700 (PDT)
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20060629135826.20328067.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29/06/06, Andrew Morton <akpm@osdl.org> wrote:
[snip]
> OK.  Perhaps try setting 8k stacks?
>
> Disable lockdep?
>

I don't see that now. I will try to reproduce this with a previous
config + Ingo's "Ignore loglevel on printks" patch.

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
