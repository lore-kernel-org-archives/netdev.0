From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: ASIX 88772
Date: Thu, 2 Oct 2014 10:16:59 +0200
Message-ID: <CABkLObq1KBL5=OjVU_yBLi-MqsuCr-NwhMbFOo1Up5PpRDixaw@mail.gmail.com>
References: <C89EFD3CD56F64468D3D206D683A8D2203863DD8@ldam-msx2.fugro-nl.local>
	<C89EFD3CD56F64468D3D206D683A8D2203864153@ldam-msx2.fugro-nl.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Grant Grundler <grundler@chromium.org>,
	Freddy Xin <freddy@asix.com.tw>, olofj@chromium.org
To: "Stam, Michel [FINT]" <M.Stam@fugro.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:56331 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbaJBIRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 04:17:00 -0400
Received: by mail-wg0-f48.google.com with SMTP id n12so2390511wgh.31
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 01:16:59 -0700 (PDT)
In-Reply-To: <C89EFD3CD56F64468D3D206D683A8D2203864153@ldam-msx2.fugro-nl.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michel,

On Thu, Oct 2, 2014 at 9:50 AM, Stam, Michel [FINT] <M.Stam@fugro.nl> wrote:
> LS,
>
> Is it possible for someone to apply this patch?

Patches must be sent in the email body, not as an attachment. Please
use git send-email to send the patch, other mail clients will most
likely break the patch as you already noted. Please send the patch
again.

You should also take the authors of the patch that made the change
(4ad1438f) that you would like to revert on cc, Freddy Xin
<freddy@asix.com.tw> and Grant Grundler <grundler@chromium.org> in
this case.

Regards,
Christian
