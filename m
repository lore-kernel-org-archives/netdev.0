From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH] RDS: keep data type consistent in the user
 visible header
Date: Tue, 21 Feb 2017 06:55:01 -0800
Message-ID: <de2016e9-de65-221e-bb9b-d45658bcc60d@oracle.com>
References: <1487387747-5324-1-git-send-email-santosh.shilimkar@oracle.com>
 <20170220.101951.663166903772216217.davem@davemloft.net>
 <20170220153722.GB16561@oracle.com>
 <20170220.103912.194197218422769191.davem@davemloft.net>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6CA26@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        "'David Miller'" <davem@davemloft.net>,
        "sowmini.varadhan@oracle.com" <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE6CA26@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/21/17 6:29 AM, David Laight wrote:
>> The entire file should use the proper "__uX" kernel types
>> rather than the uint* ones.
>
> The uint* ones are part of the C standard :-)
>
Should have been uint*_t :-)
