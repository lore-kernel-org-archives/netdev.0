From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Sat, 15 Sep 2007 10:35:16 -0400
Message-ID: <46EBEDA4.3070103@garzik.org>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org> <20070915135633.GA19482@lemming.cita.utoronto.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Robin Humble <rjh@cita.utoronto.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48321 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266AbXIOOfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2007 10:35:19 -0400
In-Reply-To: <20070915135633.GA19482@lemming.cita.utoronto.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robin Humble wrote:
> On Fri, Sep 14, 2007 at 03:07:46PM -0400, Jeff Garzik wrote:
>> It is my hope that you will put your skills towards a distributed 
>> filesystem :)  Of the current solutions, GFS (currently in kernel) 
>> scales poorly, and NFS v4.1 is amazingly bloated and overly complex.
>>
>> I've been waiting for years for a smart person to come along and write a 
>> POSIX-only distributed filesystem.
> 
> it's called Lustre.
> works well, scales well, is widely used, is GPL.
> sadly it's not in mainline.

Lustre is tilted far too much towards high-priced storage, and needs 
improvement before it could be considered for mainline.

	Jeff



