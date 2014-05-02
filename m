From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ip: add nlmon as a device type to help message
Date: Fri, 02 May 2014 08:45:18 +0200
Message-ID: <53633EFE.6050105@redhat.com>
References: <1398998087-4242-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750841AbaEBGpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2014 02:45:22 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s426jKoV009682
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 2 May 2014 02:45:21 -0400
In-Reply-To: <1398998087-4242-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2014 04:34 AM, Masatake YAMATO wrote:
> Though nlmon device can be added, it was not listed
> in the output of "ip link help".
>
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
