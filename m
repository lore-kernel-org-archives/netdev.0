From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 00/12] nfp: add flower app with representors
Date: Thu, 22 Jun 2017 17:54:03 +0300
Message-ID: <CAJ3xEMimQ1C64sy2P9qOM0=ya5-ZPzgvLFAdaMMPNzj2OqMP3Q@mail.gmail.com>
References: <1497994580-6271-1-git-send-email-simon.horman@netronome.com> <20170621.154021.1131884877414381697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Simon Horman <simon.horman@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33608 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbdFVOyE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 10:54:04 -0400
Received: by mail-oi0-f50.google.com with SMTP id p66so10265798oia.0
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 07:54:04 -0700 (PDT)
In-Reply-To: <20170621.154021.1131884877414381697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 10:40 PM, David Miller <davem@davemloft.net> wrote:
>
> Simon it looks like Or has some more questions about how these
> representers will work and operate.
>
> So I'm going to mark this series as "deferred" in patchwork while
> you two sort out that conversation.


Hi Dave,

Jakub and Simon provided answers for the questions on the general
architecture of the framework, how things are configured and how it
will work for more use-cases, seems very well done.

FWIW, I posted now two point comments on V2, I guess we can continue the review
from there, but this is on much more concrete matters.

Or.
