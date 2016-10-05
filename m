From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 1/3] openvswitch: normalize vlan rx path
Date: Wed, 5 Oct 2016 23:07:50 +0200
Message-ID: <20161005230750.51a42d05@griffin>
References: <cover.1475672568.git.jbenc@redhat.com>
        <c7f44c08104958c86c68d98f1e093d754b0ca61b.1475672569.git.jbenc@redhat.com>
        <CAHsH6Gvha_Saq8SVaLhsXzNggAOwbdu6n5xLQD7HFhYweJMsmw@mail.gmail.com>
        <20161005192319.713d92e1@griffin>
        <CAHsH6GvO=F38jXo18=3n1+w+sojRtRcLgbdE9PrGbGyB4vmoEA@mail.gmail.com>
        <20161005184426.GQ25403@egarver>
        <20161005210709.79732b27@griffin>
        <20161005192132.GR25403@egarver>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eyal Birger <eyal.birger@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        pravin shelar <pshelar@ovn.org>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56036 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750700AbcJEVHz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 17:07:55 -0400
In-Reply-To: <20161005192132.GR25403@egarver>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Oct 2016 15:21:32 -0400, Eric Garver wrote:
> How about this incremental change?

Feel free to submit it as a standalone patch. It has nothing to do with
this patchset. In this particular regard, the code is identical before
and after the patchset and is in no way altered by this patch.

 Jiri
