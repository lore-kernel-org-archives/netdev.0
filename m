From: Joe Jin <joe.jin@oracle.com>
Subject: Re: [NETWORK] Firmware file for tehuti
Date: Sat, 18 Dec 2010 08:09:02 +0800
Message-ID: <4D0BFB9E.9040404@oracle.com>
References: <4D0B0B70.9050306@oracle.com> <1292594691.3136.840.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Guru Anbalagane <guru.anbalagane@oracle.com>,
	"greg.marsden@oracle.com" <greg.marsden@oracle.com>,
	DuanZhenzhong <zhenzhong.duan@oracle.com>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:53164 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756370Ab0LRAKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 19:10:20 -0500
In-Reply-To: <1292594691.3136.840.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> My first version of the patch to use request_firmware() used
> "tehuti/firmware.bin".  I then found Jaswinder's patch at
> <http://git.infradead.org/users/jaswinder/firm-jsr-2.6.git?a=commitdiff;h=e41f3e5f8c5110871e376a2566b8eea2932b813b>,
> which used the name "tehuti/bdx.bin".  For some reason I changed the
> name of the firmware file in my patch to match that, but not the code.
>

Thanks for the confirmation.
> Ben.
>


-- 
Oracle<http://www.oracle.com>
Joe Jin | Team Leader, Software Development | +8610.8278.6295
ORACLE | Linux and Virtualization
Incubator Building 2-A ZPark | Beijing China, 100094

