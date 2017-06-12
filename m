From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH 1/2] hsr: fix coding style issues
Date: Mon, 12 Jun 2017 14:21:26 -0400
Message-ID: <593EDBA6.2080302@ti.com>
References: <1496701907-29376-1-git-send-email-m-karicheri2@ti.com>
 <20170606.160937.2113672006487973562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <arvid.brodin@alten.se>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606.160937.2113672006487973562.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2017 04:09 PM, David Miller wrote:
> 
> Please do not mix cleanups with legitimate bug fixes.  Also, when posting
> a multi-patch series, you must always provide an appropriate "[PATCH 0/N]"
> header posting that describes what you series is doing at a high level,
> how it is doing it, and why it is doing it that way.
> 
> For this, submit the erroneous warning removal against 'net' as a single
> patch.  And then once that propagates into the 'net-next' tree you can
> submit the coding style cleanups against 'net-next', thanks.
> 
Thanks. Will do

-- 
Murali Karicheri
Linux Kernel, Keystone
