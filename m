From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Sat, 15 Sep 2007 08:44:00 -0400
Message-ID: <780b6f780709150544m219002fdocab86a6646f611ae@mail.gmail.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
	 <46EAC25B.2060404@intel.com>
	 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
	 <46EAF644.1040006@intel.com>
	 <780b6f780709141737w4e17f0a8r944555f27f7344dd@mail.gmail.com>
	 <20070915010916.d8bd035d.billfink@mindspring.com>
	 <780b6f780709150527v50ff71b2sf9e5d17b62afeb86@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Kok, Auke" <auke-jan.h.kok@intel.com>
To: "Bill Fink" <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:53917 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbXIOMoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 08:44:01 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1312954wah
        for <netdev@vger.kernel.org>; Sat, 15 Sep 2007 05:44:00 -0700 (PDT)
In-Reply-To: <780b6f780709150527v50ff71b2sf9e5d17b62afeb86@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I also upgraded to samba-3.0.26-1 and so far the problem seems
significantly less frequent and limited, unfortunately, to the
'silent' corruption. I am still running with HW checksumming off, with
a new cable (cat6, even though it's 50cm long, so I could probably be
running chicken wire), on the original switch port.
I wonder why this isn't more widespread?

LF / now very puzzled
