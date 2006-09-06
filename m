From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [REVISED] [PATCH] ethtool v4: add autoneg advertise feature
Date: Wed, 6 Sep 2006 11:19:51 -0700
Message-ID: <9929d2390609061119g344bd484tca0ef2ada6c5eb34@mail.gmail.com>
References: <20060905151016.8244.16888.stgit@jtkirshe-sled.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John Rociak" <john.ronciak@intel.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:63795 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751494AbWIFSTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 14:19:53 -0400
Received: by ug-out-1314.google.com with SMTP id m3so2387625ugc
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2006 11:19:51 -0700 (PDT)
To: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>
In-Reply-To: <20060905151016.8244.16888.stgit@jtkirshe-sled.jf.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/5/06, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>
> adds the ability to change the advertised speed and duplex for a network interface.  Previously, a network interface was only able to advertise all supported speed's and duplex's, or one individual speed and duplex.  The feature allows the user to choose which supported speed's and duplex's to advertise by using the hex value.
>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>
> ---

This patch can be pull from the following location:

git pull git://lost.foo-projects.org/~jtkirshe/ethtool e1000

-- 
Cheers,
Jeff
