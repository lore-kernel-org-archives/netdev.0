From: Rick Jones <rick.jones2@hp.com>
Subject: Re: smp_affinity, MSI-X and 2.6.21.1
Date: Mon, 07 May 2007 17:09:58 -0700
Message-ID: <463FBFD6.7070301@hp.com>
References: <463F91D3.3010000@hp.com> <1178579220.3819.1.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:55914 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967457AbXEHAKC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 20:10:02 -0400
In-Reply-To: <1178579220.3819.1.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> On Mon, 2007-05-07 at 13:53 -0700, Rick Jones wrote:
> 
>>Folks -
>>
>>Is it a bug, or a feature that after changing a device's smp_affinity via echo 
>>"N" >> /proc/irq/M/smp_affinity that the new mask isn't visible via cat 
>>/proc/irq/M/smp_affinity until after actual interrupts are taken?\
> 
> 
> that's known and expected behavior

well, expected by those in the know anyway :)

thanks.

rick jones
