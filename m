From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH resend] ip: add nlmon as a device type to help message
Date: Tue, 15 Jul 2014 11:29:04 +0200
Message-ID: <53C4F460.3020805@redhat.com>
References: <1405414636-31362-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757853AbaGOJ3J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 05:29:09 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s6F9T7vZ005386
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 05:29:08 -0400
In-Reply-To: <1405414636-31362-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 10:57 AM, Masatake YAMATO wrote:
> Though nlmon device can be added, it was not listed
> in the output of "ip link help".
>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

No need to resend, your original patch is still queued
up here: http://patchwork.ozlabs.org/patch/358864/
