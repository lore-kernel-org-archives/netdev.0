From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [RESEND] benet: BladeEngine 10Gb NIC driver
Date: Tue, 16 Sep 2008 02:00:21 -0700
Message-ID: <20080916090021.c4a58c42@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:36396 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbYIPJAW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 05:00:22 -0400
Received: from 124.30.166.146 ([124.30.166.146])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Tue, 16 Sep 2008 02:00:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

It is more than two months since the benet driver patch was made available as a single file as suggeted by you :

ftp://ftp.serverengines.com/0001.benet.patch

I have not seen this applied.  Is there any reason for not applying this  patch ?  Do you want a patch against the latest git tree ?

Thanks.

Subbu
-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
Behalf Of Subbu Seetharaman
Sent: Wednesday, July 09, 2008 7:25 AM
To: Jeff Garzik
Cc: 'Randy Dunlap'; 'Bill Fink'; netdev@vger.kernel.org
Subject: Re: [PATCH 8/8] benet: Kconfig, Makefile, MAINTAINERS

Jeff,

The benet driver patch with this Kconfig change is available 
as one file under under :

ftp://ftp.serverengines.com/0001.benet.patch

Thanks.

Subbu

----- Original Message -----
From: Jeff Garzik [mailto:jeff@garzik.org]
To: subbu [mailto:subbus@serverengines.com]
Cc: 'Randy Dunlap' [mailto:randy.dunlap@oracle.com], 'Bill Fink'
[mailto:billfink@mindspring.com], netdev@vger.kernel.org
Sent: Mon, 07 Jul 2008 06:57:48 -0700
Subject: Re: [PATCH 8/8] benet: Kconfig, Makefile, MAINTAINERS


subbu wrote:
> Thanks Randy and Bill.  I will wait couple more
> days for any more comments before sending the updated patch.

Also, if you have a link to a patch that provides everything in one 
file, that would be useful for me.

	Jeff

____________________________________________________________________________
_______
This message, together with any attachment(s), contains confidential and
proprietary information of
ServerEngines Corporation and is intended only for the designated
recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly
prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by
reply email message and
delete all copies of this message and any attachment(s). Thank you.

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

