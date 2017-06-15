From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: restrict advertized checksum offloads
 to just IP
Date: Thu, 15 Jun 2017 11:54:51 -0700
Message-ID: <d8203dbd-2873-afcf-91b9-f7ff7495d3bb@oracle.com>
References: <1497480217-391315-1-git-send-email-shannon.nelson@oracle.com>
 <20170615.142314.2129688024540050765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170615.142314.2129688024540050765.davem@davemloft.net>
Content-Language: en-US
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/15/2017 11:23 AM, David Miller wrote:
> 
> Applied, but this bug must be fixed properly and ipv6 checksumming
> properly supported.
> 
> Thanks.
> 

Understood - we just wanted first to stop the bleeding while we think 
about how to do this right.

Thanks,
sln
