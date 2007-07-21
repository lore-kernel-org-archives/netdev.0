From: "Andrew Gallatin" <gallatin@gmail.com>
Subject: Re: [RFC 0/1] lro: Generic Large Receive Offload for TCP traffic
Date: Sat, 21 Jul 2007 10:03:09 -0400
Message-ID: <3cea2ee30707210703p5865ef77j103eb9e7499dd95b@mail.gmail.com>
References: <200707201741.45079.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Christoph Raisch" <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	"Marcus Eder" <meder@de.ibm.com>,
	"Thomas Klein" <tklein@de.ibm.com>,
	"Stefan Roscher" <stefan.roscher@de.ibm.com>,
	"David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
To: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:49208 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763345AbXGUODL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 10:03:11 -0400
Received: by ug-out-1314.google.com with SMTP id j3so791636ugf
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 07:03:10 -0700 (PDT)
In-Reply-To: <200707201741.45079.ossthema@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/20/07, Jan-Bernd Themann <ossthema@de.ibm.com> wrote:
> Hi,
>
> Thanks a lot for your comments so far.
> This generic LRO patch differs from the last one in several points.
> A new interface for a "receive in pages" mode has been added and tested
> with an eHEA prototype. Seems to work well.
>
> Does this extended interface seem to be sufficient?

Thank you for this!

At least for me, I find it is best to try to use an interface rather
than simply reading a diff.  So I will port Myri10GE to use the new
interface so that I can give better feedback,  I'll try my best to do
this  by early next week.

Thank you again,

Drew
