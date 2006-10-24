From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 3/3] Kconfig update for regulatory domain
Date: Tue, 24 Oct 2006 01:09:48 -0400
Message-ID: <43e72e890610232209u70325843p897f286f9ab27e83@mail.gmail.com>
References: <43e72e890610231551w5f5e947ena6d9a5d6f9a70ad9@mail.gmail.com>
	 <20061024010455.GB3552@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:29223 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1752006AbWJXFJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 01:09:50 -0400
Received: by nf-out-0910.google.com with SMTP id c2so83884nfe
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2006 22:09:48 -0700 (PDT)
To: "David Kimdon" <david.kimdon@devicescape.com>
In-Reply-To: <20061024010455.GB3552@devicescape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/06, David Kimdon <david.kimdon@devicescape.com> wrote:
> This last chunk is broken:
> . . .
> Hunk #2 FAILED at 90.

You can ignore this hunk.

>
> > --- wireless-dev-old/net/d80211/Kconfig       2006-10-23 13:56:11.000000000 -0400
> > +++ wireless-dev/net/d80211/Kconfig   2006-10-23 17:04:12.000000000 -0400
> > @@ -16,8 +90,6 @@ config D80211_LEDS
> >       This option enables a few LED triggers for different
> >       packet receive/transmit events.
> >
> > -config D80211_
> > -
> >  config D80211_DEBUG
> >       bool "Enable debugging output"
> >       depends on D80211
>
>
