From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 0/4] Pull request for 'sis190' branch
Date: Thu, 27 Dec 2007 00:17:23 +0100
Message-ID: <20071226231723.GA4547@electric-eye.fr.zoreil.com>
References: <20071210222732.GA8675@electric-eye.fr.zoreil.com> <476703B9.7010604@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"K.M. Liu" <kmliu@sis.com.tw>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60937 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750947AbXLZX1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 18:27:21 -0500
Content-Disposition: inline
In-Reply-To: <476703B9.7010604@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> :
[...]
>> Shortlog
>> --------
>>
>> Francois Romieu (4):
>>       sis190: add cmos ram access code for the SiS19x/968 chipset pair
>>       sis190: remove duplicate INIT_WORK
>>       sis190: mdio operation failure is not correctly detected
>>       sis190: scheduling while atomic error
>
> pulled into #upstream

Imho no owner of a 968 south bridge will be able to use his integrated
network device as long as "sis190: add cmos ram access code ..." is
not included upstream. Waiting for 2.6.25 means no hardware support
before march 2008.

-- 
Ueimor
