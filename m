From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH] eeprom_93cx6: Add write support
Date: Thu, 21 Dec 2006 08:22:12 +0100
Message-ID: <a32f33a40612202322v349caae9j9078bb590239c999@mail.gmail.com>
References: <200612131956.51000.IvDoorn@gmail.com>
	 <20061213190651.GF26412@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>,
	netdev@vger.kernel.org, "Michael Wu" <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:44103 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422777AbWLUHWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 02:22:14 -0500
Received: by ug-out-1314.google.com with SMTP id 44so2527470uga
        for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 23:22:13 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213190651.GF26412@csclub.uwaterloo.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This patch addes support for writing to the eeprom,
> this also moves some duplicate code into seperate functions.

John: Do you want me to merge this path with the eeprom merge patch,
and move the patch that moves rt2x00 to use this eeprom module into a
separate patch or all these 2 patches good enough?

Ivo
