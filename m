From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Wed, 06 Sep 2017 16:31:11 -0700 (PDT)
Message-ID: <20170906.163111.1134793014413389479.davem@davemloft.net>
References: <20170905.214143.826912481689443792.davem@davemloft.net>
        <CA+55aFw0KNTKFrRHk5hthDGTGgL9BGt9G=x_m9Tz7m_-pN+NoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
        luciano.coelho@intel.com, kvalo@codeaurora.org,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxwifi@intel.com,
        linux-wireless@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFw0KNTKFrRHk5hthDGTGgL9BGt9G=x_m9Tz7m_-pN+NoA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 6 Sep 2017 16:27:15 -0700

> This pull request completely breaks Intel wireless for me.
> 
> This is my trusty old XPS 13 (9350), using Intel Wireless 8260 (rev 3a).
> 
> That remains a very standard Intel machine with absolutely zero odd
> things going on.
> 
> The firmware is iwlwifi-8000C-28.ucode from
> iwl7260-firmware-25.30.13.0-75.fc26.noarch, and the kernel reports
 ...

Johannes and other Intel folks please look into this.
