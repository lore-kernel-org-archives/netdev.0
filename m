From: Mauro Dreissig <mukadr@gmail.com>
Subject: Re: [PATCH 1/4] staging: rtl8712: Remove casts between void * and
 type *
Date: Tue, 24 Nov 2015 13:18:06 -0200
Message-ID: <56547FAE.5040809@gmail.com>
References: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
 <1448367582-8041-2-git-send-email-mukadr@gmail.com>
 <20151124130730.GZ18797@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35358 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399AbbKXPSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 10:18:13 -0500
Received: by qgec40 with SMTP id c40so12375559qge.2
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 07:18:13 -0800 (PST)
In-Reply-To: <20151124130730.GZ18797@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24-11-2015 11:07, Dan Carpenter wrote:
> On Tue, Nov 24, 2015 at 10:19:39AM -0200, Mauro Dreissig wrote:
>> Cleaning rtl871x_ioctl_rtl.c.
>>
> 
> It's better if you think about the header and the body as two different
> things.  Just repeat the title but with more information.
> 
> regards,
> dan carpenter
> 

Will fix that, thanks!
