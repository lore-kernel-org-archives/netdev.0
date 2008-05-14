From: Filip Aben <f.aben@option.com>
Subject: Re: HSO: add option hso driver
Date: Wed, 14 May 2008 17:12:46 +0200
Message-ID: <482B016E.2080306@option.com>
References: <20080513215134.GC6139@kroah.com> <20080513232727.21c74bb2@core> <482A23B8.7050705@pobox.com> <20080514015815.GA29785@kroah.com> <20080514045712.GA2843@kroah.com> <482AF058.3020505@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:12292 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbYENPMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 11:12:48 -0400
In-Reply-To: <482AF058.3020505@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paulius Zaleckas schreef:
> Greg Kroah-Hartman wrote:
>> +#define DRIVER_VERSION            "1.2"
> 
> Maybe we should bump the version?
> Now it is the same as the different driver at PHARscape.

Probably the best thing would be to drop it altogether as it doesn't 
make a lot of sense to maintain it in the kernel. Also the pharscape 
version will continue to live it's own life till the hso driver is fully 
settled in an official kernel, so version conflicts would be bound to 
happen anyway.

Regards,

Filip-

