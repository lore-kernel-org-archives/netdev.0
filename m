From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v1 00/11] A flow API
Date: Thu, 8 Jan 2015 17:14:12 +0200
Message-ID: <CAJ3xEMjb+pG3TR+r0huNVSGkuPE9i7EZeHO4SQkcfm=WA6zMeA@mail.gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:43208 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbbAHPON convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:14:13 -0500
Received: by mail-oi0-f49.google.com with SMTP id a141so7727294oig.8
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 07:14:13 -0800 (PST)
In-Reply-To: <20141231194057.31070.5244.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 9:45 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> For some examples and maybe a bit more illustrative description I
> posted a quickly typed up set of notes on github io pages. Here we
> can show the description along with images produced by the flow tool
> showing the pipeline. Once we settle a bit more on the API we should
> probably do a clean up of this and other threads happening and commit
> something to the Documentation directory.
>
>  http://jrfastab.github.io/jekyll/update/2014/12/21/flow-api.html

John, Going over your excellent tutorial, the distinction between
action and operation isn=E2=80=99t clear... specifically, the paragraph
=E2=80=9CAlthough this gives us a list of actions we can perform on a p=
acket
and a set of argument to give the action so we can use them it does
not supply the operations performed on the packet=E2=80=9D is a bit vag=
ue.

Or.
