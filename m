From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Fri, 21 Jul 2006 14:02:43 +0100
Message-ID: <44C0D073.8080205@gentoo.org>
References: <20060601200200.A0E0689D05D@zog.reactivated.net> <20060608143133.7e36a0b7.rdunlap@xenotime.net> <4488DF85.3090901@garzik.org> <20060609183358.GA5835@electric-eye.fr.zoreil.com> <4489C290.6020705@garzik.org> <20060610120523.GA24288@electric-eye.fr.zoreil.com> <20060610224811.GA3256@electric-eye.fr.zoreil.com> <20060611233022.GA11776@electric-eye.fr.zoreil.com> <20060718221416.GA1430@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	"Randy.Dunlap" <rdunlap@xenotime.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:51074 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750706AbWGUNCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 09:02:32 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060718221416.GA1430@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

Francois Romieu wrote:
> Despite the fact that the newer 8168 has been reported to only work with an
> extra alignment (gross hack: s/NET_IP_ALIGN/8/), the serie seems otherwise
> fine.
> 
> I'll submit an updated serie to correctly support the 8168.


Any word on the updated 8168 patch? Would love to get that supported in 
Gentoo's upcoming release media, if the patch is ready.

Thanks!
Daniel
