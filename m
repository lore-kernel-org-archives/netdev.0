From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: RE: [PATCH net 0/3] bna: misc bugfixes
Date: Sat, 30 May 2015 01:22:42 +0000
Message-ID: <2552F74A0BCCBE4DBE2AD218C81B28110844E55B@avmb3.qlogic.org>
References: <1432847408-5066-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Ivan Vecera <ivecera@redhat.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:60086 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753968AbbE3BWs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 21:22:48 -0400
In-Reply-To: <1432847408-5066-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Ivan Vecera [mailto:ivecera@redhat.com]
> Sent: Thursday, May 28, 2015 2:10 PM
> 
> These patches fix several bugs found during device initialization debugging.
> 
> Cc: Rasesh Mody <rasesh.mody@qlogic.com>
> 
> Ivan Vecera (3):
>   bna: fix firmware loading on big-endian machines
>   bna: remove unreasonable iocpf timer start
>   bna: fix soft lock-up during firmware initialization failure
> 
>  drivers/net/ethernet/brocade/bna/bfa_ioc.c   | 4 ++--
>  drivers/net/ethernet/brocade/bna/bnad.c      | 4 ----
>  drivers/net/ethernet/brocade/bna/cna_fwimg.c | 7 +++++++
>  3 files changed, 9 insertions(+), 6 deletions(-)

Acked-by: Rasesh Mody <rasesh.mody@qlogic.com>

Thanks!
-Rasesh
