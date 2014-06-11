From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH resend] ip: add nlmon as a device type to help message
Date: Wed, 11 Jun 2014 23:53:05 +0200
Message-ID: <5398CFC1.4040904@redhat.com>
References: <1402513718-19035-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42909 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958AbaFKVxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 17:53:08 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s5BLr7Np002592
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 17:53:07 -0400
In-Reply-To: <1402513718-19035-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2014 09:08 PM, Masatake YAMATO wrote:
> Though nlmon device can be added, it was not listed
> in the output of "ip link help".
>
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
