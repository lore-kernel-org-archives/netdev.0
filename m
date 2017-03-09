From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] sunvnet: better connection management
Date: Wed, 08 Mar 2017 21:59:51 -0800 (PST)
Message-ID: <20170308.215951.1257204853862874733.davem@davemloft.net>
References: <1488842132-512058-1-git-send-email-shannon.nelson@oracle.com>
        <80e05f39-ea92-bfdf-b7d6-2cee47c8bab6@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <80e05f39-ea92-bfdf-b7d6-2cee47c8bab6@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Wed, 8 Mar 2017 15:04:45 -0800

> On 3/6/2017 3:15 PM, Shannon Nelson wrote:
>> These patches remove some problems in handling of carrier state
>> with the ldmvsw vswitch, remove  an xoff misuse in sunvnet, and
>> add stats for debug and tracking of point-to-point connections
>> between the ldom VMs.
> 
> Further testing shows a problem in one of the patches, so there will
> be a V2 coming.

Ok.
