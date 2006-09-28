From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH] bcm43xx-softmac: fix warning from ignoring returned value from pci_enable_device
Date: Thu, 28 Sep 2006 19:26:50 +1200
Message-ID: <5640c7e00609280026m4c734f29i76a92860296d4b8a@mail.gmail.com>
References: <451B595F.mailDJI11YVSN@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>,
	"Michael Buesch" <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, "Stefano Brivio" <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0708.google.com ([64.233.184.131]:19005 "EHLO
	wr-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751729AbWI1H0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 03:26:51 -0400
Received: by wr-out-f131.google.com with SMTP id 20so19346wra
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 00:26:50 -0700 (PDT)
To: "Larry Finger" <Larry.Finger@lwfinger.net>
In-Reply-To: <451B595F.mailDJI11YVSN@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/28/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> Linus's tree now has a configuration option that prints a warning whenever
> the returned value of any routine is ignored. This patch fixes the only such
> warning for bcm43xx.
>
Can you tell me how to make this check please so I can check my code
in the kernel? I could look it up but obviously you can tell me
quickly :-)

Regards,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
