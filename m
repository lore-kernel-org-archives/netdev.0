From: David Miller <davem@davemloft.net>
Subject: Re: e100: checksum mismatch on 82551ER rev10
Date: Fri, 04 Aug 2006 04:20:24 -0700 (PDT)
Message-ID: <20060804.042024.63108922.davem@davemloft.net>
References: <Pine.LNX.4.61.0607311653360.24450@e-smith.charlieb.ott.istop.com>
	<44D0D7CA.2060001@intel.com>
	<62b0912f0608040404p59545a0asc7f5fc5f537ec32c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, charlieb@budge.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49795
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932403AbWHDLUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:20:20 -0400
To: molle.bestefich@gmail.com
In-Reply-To: <62b0912f0608040404p59545a0asc7f5fc5f537ec32c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Molle Bestefich" <molle.bestefich@gmail.com>
Date: Fri, 4 Aug 2006 13:04:07 +0200

> You're trying to pull Linux end users into a war between Intel and
> it's vendors, so you can make end users scream at the vendors when
> they forget to run the checksum tool.

I totally agree, Intel driver maintainers generally act like complete
idiots in these kinds of situations.

If the EEPROM has a broken checksum, the user should have an option
that allows him to try and use the device anyways, end of story.

It is only self serving to not provide this option to the user.

People make errors, EEPROM's get shipped with bad checksums but the
device might still be usable.  That is life get over it.
