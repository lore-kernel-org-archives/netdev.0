From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 23 Jan 2007 14:01:33 -0500
Message-ID: <9e4733910701231101q5a5490b7m806b1633c177acd@mail.gmail.com>
References: <20070116185524.GA5681@dmt>
	 <1169056884.9175.66.camel@johannes.berg> <20070122112613.GA3038@dmt>
	 <9e4733910701220720x47506091m357cbf9e5deb3903@mail.gmail.com>
	 <1169566914.3649.4.camel@johannes.berg>
	 <9e4733910701230818g13dc82a2kf0972b8543db449f@mail.gmail.com>
	 <1169571273.3649.12.camel@johannes.berg>
	 <9e4733910701230914t52b39f2dha00ddfcec22fd3bd@mail.gmail.com>
	 <1169575198.2777.37.camel@localhost.localdomain>
	 <1169577039.3649.29.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Dan Williams" <dcbw@redhat.com>,
	"Marcelo Tosatti" <marcelo@kvack.org>, "Jiri Benc" <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	"Arnd Bergmann" <arnd@arndb.de>,
	"Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>,
	"Johannes Berg" <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:65351 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965437AbXAWTBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 14:01:34 -0500
Received: by py-out-1112.google.com with SMTP id a29so839784pyi
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 11:01:33 -0800 (PST)
To: "Daniel Drake" <dsd@gentoo.org>
In-Reply-To: <1169577039.3649.29.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/23/07, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Tue, 2007-01-23 at 12:59 -0500, Dan Williams wrote:
>
> > I believe it needs to at least support 4 address frames, which usually
> > requires firmware changes on fullmac cards, but fully softmac cards
> > (atheros, broadcom) probably would not.
>
> .11s also introduces new frame types/subtypes that probably need to be
> ACKed which usually the firmware won't do since it doesn't understand
> those frame types/subtypes yet.

Daniel,  would the Zydas employees be interested in supplying us with
a MAC that would support the development of a software based 802.11s
stack?

-- 
Jon Smirl
jonsmirl@gmail.com
