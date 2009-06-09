From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/2 v3] netdev: smsc911x: allow
	building on any system
Date: Tue, 9 Jun 2009 07:08:20 -0400
Message-ID: <8bd0f97a0906090408gfd07941x435a65b3758d6b25@mail.gmail.com>
References: <20090609.013718.135786197.davem@davemloft.net>
	<1244538819-11305-1-git-send-email-vapier@gentoo.org> <20090609.035956.164474046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:48086 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755094AbZFILIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 07:08:39 -0400
Received: by gxk10 with SMTP id 10so3053267gxk.13
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 04:08:40 -0700 (PDT)
In-Reply-To: <20090609.035956.164474046.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 9, 2009 at 06:59, David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
>> The smsc911x driver should build fine on any system as it contains no arch
>> specific code (all platform resources), and any platform that has
>> appropriate resources should run fine.
>>
>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>
> Where is patch 2/2 :-)

meh, call this patch 1.5 since it doesnt replace the previous 1/2 like
v2 did.  there is no 2/2.
-mike
