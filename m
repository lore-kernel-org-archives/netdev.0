From: "Molle Bestefich" <molle.bestefich@gmail.com>
Subject: Re: e100: checksum mismatch on 82551ER rev10
Date: Sat, 5 Aug 2006 15:28:40 +0200
Message-ID: <62b0912f0608050628v78dcc5c2k75970d6d32f90748@mail.gmail.com>
References: <44D0D7CA.2060001@intel.com>
	 <62b0912f0608040404p59545a0asc7f5fc5f537ec32c@mail.gmail.com>
	 <20060804.042024.63108922.davem@davemloft.net>
	 <20060804.042834.78730901.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, charlieb@budge.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:57987 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1422649AbWHEN2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 09:28:42 -0400
Received: by nf-out-0910.google.com with SMTP id k26so196866nfc
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2006 06:28:41 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060804.042834.78730901.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Please put the option into the e100 driver to allow trying to use the
> device even if the EEPROM checksum is wrong.

Whee, the users win! :-)

> If an Intel developer doesn't do it, I will.

I hope you don't piss off the nice guys at Intel who contribute source
code to the Linux kernel so much that they go away.

For what it's worth, a redistributable utility to fix the EEPROM
checksum would be just as fine a solution (for me)...  if only one was
available.
